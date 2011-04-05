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

	 ro_model = ro_container.research_objects.find_or_create_by_name(name)
	 
	 dropbox = dropbox_account.get_dropbox_session

	 sync_ro_folder(ro_metadata.path, dropbox, ro_container)
	 	
	 	
	 end
	  
	 
 	 # TODO: sync each file/folder
 	 
  end

  def sync_ro_folder(path, dropbox, ro_container, parent=nil)
      dropbox.list(ro_metadata.path).each do |child|
      	
		# blah      		
      		
      		
      	if child.directory?
      		sync_ro_folder(child.path, dropbox, ro_container)
      	end
      end      
  end
  
end
