class DropboxAccount < ActiveRecord::Base
  
  include DatabaseValidation
  
  attr_accessible :user_id,
                  :user,
                  :dropbox_user_id,
                  :access_token,
                  :access_secret
  
  validates :user,
            :existence => true
  
  belongs_to :user,
             :autosave => true
  
  def setup_user!(account_info)
    internal_user = User.find_or_create_by_email(account_info.email, :name => account_info.display_name)
    internal_user.confirm!
    
    self.user = internal_user
  end
  
end
