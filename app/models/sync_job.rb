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
  
  belongs_to :dropbox_account
  
  def started?
    !started_at.blank?
  end
  
  def finished?
    !finished_at.blank?
  end
  
  def run
    current_stats = { }
    
    start!
    
    workspace = dropbox_account.get_workspace
    
    if workspace
      begin
        update_status! :running
        
        
      rescue Exception => ex
        Util.log_exception ex, :error, "Exception occurred during SyncJob#run for SyncJob ID #{id}"
        status :failed
        error_message = "A fatal error occurred during sync. See logs for exception details."
        save!
      end
    else
      status = :failed
      error_message = "Could not access workspace - #{dropbox_account.workspace_id}"
      save!
    end
    
    finish!
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
  
end
