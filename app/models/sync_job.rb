# == Schema Information
# Schema version: 20110407193210
#
# Table name: sync_jobs
#
#  id                                   :integer(4)      not null, primary key
#  started_at                           :datetime
#  finished_at                          :datetime
#  status_code                          :string(255)     not null
#  created_at                           :datetime
#  updated_at                           :datetime
#  error_message                        :string(255)
#  dropbox_research_object_container_id :integer(4)
#
# Indexes
#
#  index_sync_jobs_on_dropbox_research_object_container_id  (dropbox_research_object_container_id)
#  index_sync_jobs_on_dbox_ro_container_id_and_status       (dropbox_research_object_container_id,status_code)
#

require 'tempfile'
require 'dropbox'

class NotADirectoryError < Dropbox::FileError 
  
end

class SyncJob < ActiveRecord::Base
  
  APPLICATION_OCTET_STREAM = "application/octet-stream"
  
  as_enum :status,
          { :pending => "PENDING", 
            :running => "RUNNING", 
            :failed => "FAILED", 
            :success => "SUCCESS" },
          :upcase => true,
          :column => 'status_code',
          :slim => :class
          
  include DatabaseValidation
  
  validates_as_enum :status
  
  default_value_for :status, :pending
  
  attr_accessible :dropbox_research_object_container_id,
                    :status_code,
                    :error_message
  
  validates :ro_container,
             :existence => true
  
  belongs_to :ro_container,
              :class_name => "DropboxResearchObjectContainer",
              :foreign_key => "dropbox_research_object_container_id"

  # TODO: there must be an easier and DRYer way to generate the scopes below!
  
  scope :pending, lambda {
    where(:status_code => SyncJob.statuses.pending)
  }

  scope :running, lambda {
    where(:status_code => SyncJob.statuses.running)
  }

  scope :failed, lambda {
    where(:status_code => SyncJob.statuses.failed)
  }

  scope :success, lambda {
    where(:status_code => SyncJob.statuses.success)
  }

  def started?
    !self.started_at.blank?
  end
  
  def finished?
    !self.finished_at.blank?
  end

  def has_error?
    !self.error_message.blank?
  end
  
  def run
    unless started?
      ok = true

      start!

      begin
      
        # Check that the RO container folder still exists
        ro_container_metadata = ro_container.dropbox_metadata
        if ro_container_metadata.blank?
          self.status = :failed
          add_error_message "Could not access the ROs container with ID '#{ro_container.id}' and path  '#{ro_container.path}'"
          ok = false
        end

        # Check workspace is available
        workspace = ro_container.get_workspace
        if workspace.blank?
          self.status = :failed
          add_error_message "Could not access workspace with ID '#{ro_container.workspace_id}' for ROs container with ID '#{ro_container.id}'"
          ok = false
        end

        if ok
          update_status! :running
          
          synced_ros = []
          
          # Sync any dropbox folder
          ro_container_metadata.contents.each do |entry|
            if entry.directory?
              ro = sync_ro(entry, workspace)
              synced_ros << ro.name
              puts "Synced " + ro.name
            end
          end
          
          puts "Checking for new ROs on ROSRS"
          # TODO: Sync any folders only on RO side
          workspace.each do |ro| 
            puts "Checking " + ro.name
            if not synced_ros.include? ro.name
              subfolder = ro_container_metadata.path + "/" + ro.name
              puts "Making " + subfolder
              # TODO: Check that subfolder is not an existing file - the API will make (1) instead!
              folder = ro_container.get_dropbox_session.create_folder subfolder
              sync_ro(folder, workspace)
            end           
          end
          
          
          # TODO: Delete ROs now missing in dropbox

          self.status = :success

      end

      rescue Exception => ex
        Util.log_exception ex, :error, "Exception occurred during SyncJob#run for SyncJob ID '#{id}'"
        self.status = :failed
        add_error_message "Exception occurred: [#{ex.class.name}] #{ex.message}"
      end
      
      save!
      
      finish!
    end
  end

  protected
  
  def start!
    Util.say "SyncJob #{id} starting"
    update_attribute :started_at, Time.now
  end
  
  def finish!
    Util.say "SyncJob #{id} finishing"
    update_attribute :finished_at, Time.now
  end

  def update_status!(new_status)
    self.status = new_status
    save!
  end

  def add_error_message(msg)
    Util.say "Adding error message to SyncJob with ID #{id}: #{msg}"
    if self.error_message.blank?
      self.error_message = msg
    else
      self.error_message = self.error_message + "\n\n#{msg}"
    end
  end
  
  def sync_ro(ro_metadata, workspace)
    name = ro_metadata.path.gsub(/.*\//, "")
    ro_srs = workspace[name]
    if !ro_srs
      ro_srs = workspace.create_research_object(name)
    end

    version_srs = ro_srs["v1"]
    if ! version_srs
      puts "Version v1"
      version_srs = ro_srs.create_version("v1")
    end

    ro_model = ro_container.research_objects.find_or_create_by_name(name)
    ro_model.path = ro_metadata.path
    ro_model.rosrs_version_uri = version_srs.uri.to_s
    ro_model.save!

    dropbox_session = ro_container.get_dropbox_session

    puts "Syncing " + ro_model.path
    sync_ro_folder(ro_metadata.path, dropbox_session, ro_model, version_srs)

    manifest_content = version_srs.manifest_rdf
    manifest_path = ro_metadata.path + "/"
    dropbox_session.upload(StringIO.new(manifest_content), manifest_path, :as => "manifest.rdf")

    ro_model.manifest_rdf = manifest_content
    ro_model.save!
    return ro_srs
  end
	
  def make_dropbox_folders(dropbox_session, path)	  
    begin
      metadata = dropbox_session.metadata(path)
    rescue Dropbox::FileNotFoundError
      parent = path.split("/")[0..-2].join("/")
      make_dropbox_folders(dropbox_session, parent)
      metadata = dropbox_session.create_folder(path)
      # TODO: Store directory in our database?
    end
    if not metadata.directory?
      raise NotADirectoryError.new path
    end
    return metadata
  end
	  
	  
	 
  # TODO: Move these kind of functions out of the model!
  def sync_ro_folder(ro_path, dropbox_session, ro_model, version_srs, parent=ro_model)
    exists_in_dropbox = []
    dropbox_session.list(ro_path).each do |dbox_file|

      entry = parent.children.find_or_create_by_path(dbox_file.path)
      
      entry.research_object = ro_model

      relative_path = dbox_file.path[ro_model.path.length+1..-1]
      exists_in_dropbox << relative_path

      entry.name = relative_path.split('/').last

	  if dbox_file.directory?
        entry.entry_type = :directory
        entry.hash = "-1"
        entry.revision = "-1"
        entry.save!
	    sync_ro_folder(dbox_file.path, dropbox_session, ro_model, version_srs, entry)
        entry.hash = dbox_file.hash
      elsif relative_path == "manifest.rdf"
        entry.entry_type = :manifest
      else
        if entry.revision == dbox_file.revision || parent.hash == dbox_file.hash
          next
        end
        entry.entry_type = :file
        content = dropbox_session.download(dbox_file.path)
        resource = version_srs[relative_path]
        if resource
          # update the resource
          resource.content = content
        else
          puts "Uploading " + relative_path
          resource = version_srs.upload_resource(relative_path, APPLICATION_OCTET_STREAM, content)
        end
      end
      entry.revision = dbox_file.revision
      entry.save!
    end


    for existing_model in parent.children

      relative_path = existing_model.path[ro_model.path.length+1..-1]

      if exists_in_dropbox.include?(relative_path)
        puts "Not deleting " + relative_path
        next
      end

      resource = version_srs[relative_path]
      if resource
        puts "(Should have been) deleting " + relative_path
        # FIXME: This sometimes wants to delete manifest.rdf -> disabled
        #resource.delete!
      end
      #existing_model.delete
    end
    
    # Sync back again anything added on ROSRS which we did not put there
    version_srs.each do |resource| 
      if exists_in_dropbox.include?(relative_path)
        puts "Not uploading " + relative_path
        next
      end
      
      dropbox_path = ro_model.path + "/" + resource.name 
      is_folder = resource.name.ends_with? "/"
      
      file_path = dropbox_path.sub(/(.*)\/.*/, "\\1")
      file_name = resource.name.split("/")[-1]
  
      make_dropbox_folders(dropbox_session, file_path)
      # TODO: Stream from ROSRS? 

      if not is_folder
        # Make sure we can deal with binaries
        temp_file = Tempfile.new("robox-sync", :encoding => 'ascii-8bit')
        begin
          resource.download(temp_file)
          temp_file.seek(0)
          dropbox_session.upload(temp_file, file_path, :as => file_name)
          dbox_file = dropbox_session.metadata(dropbox_path)
          puts "Uploaded to Dropbox: " + dropbox_path
        ensure
          temp_file.unlink
          temp_file.close
        end
      end
      ## Put into database
      entry = parent.children.find_or_create_by_path(dropbox_path)
      entry.research_object = ro_model
      entry.name = file_name
      entry.entry_type = :file
      if is_folder
        puts "Added folder " + dropbox_path
        entry.entry_type = :directory
        entry.revision = -1
        entry.hash = -1
      else
        entry.revision = dbox_file.revision
      end
      entry.save!
    end
  
  end

end

