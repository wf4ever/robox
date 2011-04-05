class DropboxResearchObjectContainer < ActiveRecord::Base
  
  include DatabaseValidation
  
  attr_accessible :dropbox_account_id,
                  :path
                  
  validates :dropbox_account,
            :existence => true
  
  belongs_to :dropbox_account
  
end
