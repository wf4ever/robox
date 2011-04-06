# == Schema Information
# Schema version: 20110405095020
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
#  stats                                :text(16777215)
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
          :column => 'status_code'
          
  include DatabaseValidation
  
  validates_as_enum :status
  
  default_value_for :status, :pending
  
  attr_accessible :dropbox_research_object_container_id
  
  validates :ro_container,
            :existence => true
  
  belongs_to :ro_container,
             :class_name => "DropboxResearchObjectContainer",
             :foreign_key => "dropbox_research_object_container_id"
  
  serialize :stats, Hash
  
  def started?
    !started_at.blank?
  end
  
  def finished?
    !finished_at.blank?
  end
  
  def run
    unless started?
      ok = true
      current_stats = { }
      
      start!
      
      dropbox_account = ro_container.dropbox_account
      
      # Check that the RO container folder still exists
      ro_container_metadata = ro_container.dropbox_metadata
      if ro_container_metadata.blank?
        status = :failed
        add_error_message "Could not access the ROs container with ID '#{ro_container.id}' and path  '#{ro_container.path}'"
        ok = false
      end
      
      # Check workspace is available
      workspace = ro_container.get_workspace
      if workspace.blank?
        status = :failed
        add_error_message "Could not access workspace with ID '#{ro_container.workspace_id}' for ROs container with ID '#{ro_container.id}'"
        ok = false
      end 
      if ok
        begin
          update_status! :running
          
          ro_container_metadata.contents.each do |entry|
            if entry.directory?
              sync_ro(entry, dropbox_account, ro_container, workspace, stats)
            end
          end
          
          status = :success      
        rescue Exception => ex
          Util.log_exception ex, :error, "Exception occurred during SyncJob#run for SyncJob ID '#{id}'"
          status = :failed
          add_error_message "A fatal error occurred during sync. See logs for exception details."
          ok = false
        end
      end
      
      stats = current_stats
      save!
      
      finish!
    end
  end
  
  protected
  
  def start!
    update_attribute :started_at, Time.now
  end
  
  def finish!
    update_attribute :finished_at, Time.now
  end
  
  def update_status!(new_status)
    status = new_status
    save!
  end
  
  def add_error_message(msg)
    error_message ||= ''
    error_message += "#{msg}\n\n"
  end

  def sync_ro(ro_metadata, dropbox_account, ro_container, workspace, stats)
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
    dropbox = dropbox_account.get_dropbox_session

    sync_ro_folder(ro_metadata.path, dropbox, ro_model, version_srs)

    manifest_content = version_srs.manifest_rdf
    manifest_path = ro_metadata.path + "/"
    dropbox.upload(StringIO.new(manifest_content), manifest_path, :as => "manifest.rdf")

  end
	  
	 

  def sync_ro_folder(ro_path, dropbox, ro_model, version_srs, parent=ro_model)
	  dropbox.list(ro_path).each do |dbox_file|

      entry = parent.children.find_or_create_by_path(dbox_file.path)
      entry.research_object = ro_model
      
      relative_path = dbox_file.path[parent.path.length+1..-1]
      
	    if dbox_file.directory?
        entry.entry_type = :directory
        entry.hash = "-1"
        entry.revision = "-1"
        entry.save!
	      sync_ro_folder(dbox_file.path, dropbox, ro_model, version_srs, entry)
        entry.hash = dbox_file.hash
      elsif relative_path == "manifest.rdf"
        entry.entry_type = :manifest
      else
        if entry.revision == dbox_file.revision || parent.hash == dbox_file.hash
          next
        end
        entry.entry_type = :file
        content = dropbox.download(dbox_file.path)
        resource = version_srs[relative_path]
        if resource
          # update the resource
          resource.content = content
        else
          resource = version_srs.upload_resource(relative_path, APPLICATION_OCTET_STREAM, content)
        end
      end
      entry.revision = dbox_file.revision
      entry.save!
    end
  end
  
end
