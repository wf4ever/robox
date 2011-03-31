class SyncJob < ActiveRecord::Base
  
  as_enum :status, 
          { :pending => "PENDING", 
            :running => "RUNNING", 
            :failed => "FAILED", 
            :success => "SUCCESS" },
          :upcase => true
  
  attr_accessible :dropbox_account_id
  
  validates :dropbox_account,
            :existence => true
  
  belongs_to :dropbox_account
  
  
  def run
    
  end
  
end
