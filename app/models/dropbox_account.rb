# == Schema Information
# Schema version: 20110405093135
#
# Table name: dropbox_accounts
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)      not null
#  dropbox_user_id :string(255)     not null
#  access_token    :string(255)     not null
#  access_secret   :string(255)     not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_dropbox_accounts_on_user_id          (user_id)
#  index_dropbox_accounts_on_dropbox_user_id  (dropbox_user_id)
#

require 'hmac-md5'

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
  
  has_many :ro_containers,
           :class_name => "DropboxResearchObjectContainer",
           :foreign_key => "dropbox_account_id",
           :dependent => :destroy
  
  def dropbox_research_object_containers
    ro_containers
  end
  
  def setup_user!(account_info)
    internal_user = User.find_or_create_by_email(account_info.email, :name => account_info.display_name)
    internal_user.role_ids = [ Role.find_or_create_by_name('Member').id ]
    internal_user.confirm!
    
    self.user = internal_user
  end
  
  def get_dropbox_session
    if @dropbox_session.nil?
      data = [ Settings.dropbox.consumer_key, Settings.dropbox.consumer_secret, true, access_token, access_secret ].to_yaml
      @dropbox_session = Dropbox::Session.deserialize(data)
      @dropbox_session.mode = :dropbox
    end
    
    return @dropbox_session
  end
  
  def has_an_ro_container?
    return ro_containers.count > 0
  end

end
