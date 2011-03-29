class DropboxAccount < ActiveRecord::Base
  
  include DatabaseValidation
  
  attr_accessible :user_id,
                  :user,
                  :dropbox_user_id,
                  :access_token,
                  :access_secret,
                  :ro_folder
  
  validates :user,
            :existence => true
  
  belongs_to :user,
             :autosave => true
  
  def setup_user!(account_info)
    internal_user = User.find_or_create_by_email(account_info.email, :name => account_info.display_name)
    internal_user.role_ids = [ Role.find_or_create_by_name('Member').id ]
    internal_user.confirm!
    
    self.user = internal_user
  end
  
  def ensure_ro_folder
    if ro_folder.blank?
      return false
    else
      session = get_dropbox_session
      
      begin
        session.create_folder ro_folder
      rescue Dropbox::FileExistsError
        # Directory already exists!
        Util.say "DropboxAccount#ensure_ro_folder called. RO folder already exists, so it's all good!"
      end
      
      return true
    end
  end
  
  def ro_folder_metadata
    unless ro_folder.blank?
      return get_dropbox_session.metadata ro_folder
    end
  end
  
  def ro_folder_exists?
    metadata = ro_folder_metadata
    if metadata.blank?
      return false
    elsif metadata.members.include?(:is_deleted) && metadata[:is_deleted]
      return false
    end
    return true
  end
  
  def get_dropbox_session
    if @dropbox_session.nil?
      data = [ Settings.dropbox.consumer_key, Settings.dropbox.consumer_secret, true, access_token, access_secret ].to_yaml
      @dropbox_session = Dropbox::Session.deserialize(data)
      @dropbox_session.mode = :dropbox
    end
    
    return @dropbox_session
  end
  
end
