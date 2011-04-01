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
    
  end
  
end
