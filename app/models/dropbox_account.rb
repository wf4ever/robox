# == Schema Information
# Schema version: 20110401144426
#
# Table name: dropbox_accounts
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)      not null
#  dropbox_user_id    :string(255)     not null
#  access_token       :string(255)     not null
#  access_secret      :string(255)     not null
#  created_at         :datetime
#  updated_at         :datetime
#  ro_folder          :string(255)
#  workspace_password :string(255)
#

require 'hmac-md5'

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
  
  def workspace_id
    "dropbox-#{dropbox_user_id}"
  end
  
  # This registers the workspace in the RO SRS if required
  def get_workspace
    # TODO: this should really check the presence of the workspace
    # instead of just checking the password exists
    if workspace_password.blank?
      begin
        workspace_password = HMAC::MD5.new(Wf4EverDropboxConnector::Application.config.secret_token + dropbox_user_id + rand(100)).hexdigest
        workspace = DlibraClient::Workspace.create(
            Settings.rosrs.base_uri,
            workspace_id,
            workspace_password,
            Settings.rosrs.admin_username,
            Settings.rosrs.admin_password)
        
        if workspace.nil?
          return nil
        else
          save!
          return workspace
        end
      rescue Exception => ex
        Util.log_exception ex, :error, "Exception occurred during DropboxAccount#ensure_workspace for DropboxAccount ID #{id}"
        workspace_password = nil
        return nil
      end
    end
  end
  
end
