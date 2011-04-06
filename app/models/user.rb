# == Schema Information
# Schema version: 20110401105537
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)      default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  confirmation_token   :string(255)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  authentication_token :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  name                 :string(255)
#  cached_slug          :string(255)
#  deleted_at           :datetime
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#

class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  
  devise :database_authenticatable, :token_authenticatable, :recoverable, :rememberable, :trackable, :confirmable
  
  default_scope :conditions => { :deleted_at => nil }
  
  validates_presence_of     :name, :email
  # validates_presence_of     :password, :on => :create
  # validates_confirmation_of :password, :on => :create
  # validates_length_of       :password, :within => 6..30, :allow_blank => true
  validates_uniqueness_of   :email, :case_sensitive => false, :scope => :deleted_at
  validates_format_of       :email, :with => Devise::email_regexp

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  has_many :dropbox_accounts, 
           :dependent => :destroy
  
  def role?(role)
    return !!self.roles.find_by_name( Role.sanitize role )
  end
  
  def admin?
    role?('Admin')
  end

  def destroy
    self.update_attribute(:deleted_at, Time.now.utc)
  end

  def self.find_with_destroyed *args
    self.with_exclusive_scope { find(*args) }
  end

  def self.find_only_destroyed
    self.with_exclusive_scope :find => { :conditions => "deleted_at IS NOT NULL" } do
      all
    end
  end
  
  def main_dropbox_account
    has_a_dropbox_account? ? dropbox_accounts.first : nil
  end
  
  def has_a_dropbox_account?
    dropbox_accounts.count > 0
  end
  
  def has_an_ro_container?
    if has_a_dropbox_account?
      return main_dropbox_account.has_an_ro_container?
    else
      return false
    end
  end
  
  def initially_synced?
    if has_an_ro_container?
      # TODO: check that an initial sync was established
      return false
    else
      return false
    end
  end

end
