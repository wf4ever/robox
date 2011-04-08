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

          ro_container_metadata.contents.each do |entry|
            if entry.directory?
              sync_ro(entry, workspace)
            end
          end

          # TODO: Delete ROs now missing in dropbox

          self.status = :success
        end

      rescue Exception => ex
        Util.log_exception ex, :error, "Exception occurred during SyncJob#run for SyncJob ID '#{id}'"
        self.status = :failed
        add_error_message "An unknown error occurred during sync. See logs for exception details."
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
      version_srs = ro_srs.create_version("v1")
    end
    
    
    ro_model = ro_container.research_objects.find_or_create_by_name(name)
    ro_model.path = ro_metadata.path
    ro_model.save!

    dropbox_session = ro_container.get_dropbox_session

    sync_ro_folder(ro_metadata.path, dropbox_session, ro_model, version_srs)

    manifest_content = version_srs.manifest_rdf
    manifest_path = ro_metadata.path + "/"
    dropbox_session.upload(StringIO.new(manifest_content), manifest_path, :as => "manifest.rdf")
  end
	  
	 

  def sync_ro_folder(ro_path, dropbox_session, ro_model, version_srs, parent=ro_model)
    exists_in_dropbox = []
    dropbox_session.list(ro_path).each do |dbox_file|

      entry = parent.children.find_or_create_by_path(dbox_file.path)
      
      entry.research_object = ro_model


      relative_path = dbox_file.path[ro_model.path.length+1..-1]
      exists_in_dropbox << relative_path

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
        puts "Deleting " + relative_path
        resource.delete!
      end
      existing_model.delete
    end
  end

end
