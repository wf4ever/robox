# == Schema Information
# Schema version: 20110401144426
#
# Table name: sync_jobs
#
#  id                 :integer(4)      not null, primary key
#  dropbox_account_id :integer(4)      not null
#  started_at         :datetime
#  finished_at        :datetime
#  status_code        :string(255)     not null
#  created_at         :datetime
#  updated_at         :datetime
#  error_message      :string(255)
#  stats              :text(16777215)
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
  
  attr_accessible :dropbox_account_id
  
  validates :dropbox_account,
            :existence => true
  
  validate :check_ro_folder_exists
  
  belongs_to :dropbox_account
  
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
      
      # Check if the Dropbox account still has a valid ROs folder specified
      ro_folder = dropbox_account.ro_folder_metadata
      if ro_folder.blank?
        status = :failed
        add_error_message "Could not access the ROs folder '#{dropbox_account.ro_folder}' in the DropboxAccount ID '#{dropbox_account.id}'"
        ok = false
      end
      
      # Check workspace is available
      workspace = dropbox_account.get_workspace
      if workspace.blank?
        status = :failed
        add_error_message "Could not access workspace with ID '#{dropbox_account.workspace_id}'"
        ok = false
      end 
      
      if ok
        begin
          update_status! :running
          
          ro_folder.contents.each do |entry|
            if c.directory?
              sync_ro(entry, dropbox_account.get_dropbox_session, workspace, stats)
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
  
  def check_ro_folder_exists
    errors.add(:dropbox_account, "doesn't have an ROs folder (it may not exist anymore)") unless dropbox_account.ro_folder_exists?
  end
  
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
  
  def sync_ro(ro_metadata, dropbox_session, workspace, stats)
    
    
  end
  
end
