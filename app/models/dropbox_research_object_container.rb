# == Schema Information
# Schema version: 20110405122455
#
# Table name: dropbox_research_object_containers
#
#  id                 :integer(4)      not null, primary key
#  dropbox_account_id :integer(4)
#  path               :string(255)     not null
#  workspace_id       :string(255)
#  workspace_password :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_research_objects_on_dbox_account_id_and_path              (dropbox_account_id,path) UNIQUE
#  index_dropbox_research_object_containers_on_dropbox_account_id  (dropbox_account_id)
#

class DropboxResearchObjectContainer < ActiveRecord::Base
  
  include DatabaseValidation
  
  attr_accessible :dropbox_account_id,
                  :path
                  
  validates :dropbox_account,
            :existence => true
  
  belongs_to :dropbox_account
  
  has_many :sync_jobs

  has_many :research_objects,
           :class_name => "ResearchObject",
           :foreign_key => "dropbox_research_object_container_id",
           :dependent => :destroy
  
  before_save :set_workspace_credentials
  after_save :ensure_workspace_exists_in_rosrs
  after_save :ensure_folder_exists_in_dropbox

  def current_job_exists?
    self.sync_jobs.exists? :status_code => [ SyncJob.statuses(:pending, :running) ]
  end

  def pending_jobs_to_resubmit
    self.sync_jobs.pending.where("#{SyncJob.table_name}.created_at < ?", Settings.sync.pending_jobs_resubmit_after.minutes.ago)
  end
  
  def get_dropbox_session
    self.dropbox_account.get_dropbox_session
  end
  
  def dropbox_metadata
    return get_dropbox_session.metadata(path)
  end
  
  def exists?
    metadata = dropbox_metadata
    if metadata.blank?
      return false
    elsif metadata.members.include?(:is_deleted) && metadata[:is_deleted]
      return false
    end
    return true
  end
  
  def get_workspace
    unless exists?
      Util.yell "Cannot get workspace with ID '#{workspace_id}' for Dropbox RO Container ID '#{id}' as the RO container at '#{path}' is not available in the Dropbox folder"
      return nil
    end
    
    # TODO: this should really check the presence of the workspace
    # and whether it is accessible or not
    begin
      return DlibraClient::Workspace.new(Settings.rosrs.base_uri, workspace_id, workspace_password)
    rescue Exception => ex
      Util.log_exception ex, :error, "Exception occurred during DropboxResearchObjectContainer#get_workspace for DropboxResearchObjectContainer with ID #{id}"
      return nil
    end
  end
  
  protected
  
  def set_workspace_credentials
    self[:workspace_id] = "dbox-" + Base64.urlsafe_encode64(UUIDTools::UUID.random_create().raw)[0,22]
    self[:workspace_password] = HMAC::MD5.new(Wf4EverDropboxConnector::Application.config.secret_token + dropbox_account.dropbox_user_id.to_s + rand(1000).to_s).hexdigest
  end
  
  def ensure_workspace_exists_in_rosrs
    Util.say "Creating workspace '#{workspace_id}' in RO SRS...'"
    DlibraClient::Workspace.create(
        Settings.rosrs.base_uri,
        workspace_id,
        workspace_password,
        Settings.rosrs.admin_username,
        Settings.rosrs.admin_password)
  end
  
  def ensure_folder_exists_in_dropbox
    Util.say "Ensuring folder '#{path}' exists in Dropbox...'"
    
    session = get_dropbox_session
    
    begin
      session.create_folder path
    rescue Dropbox::FileExistsError
      # Directory already exists!
      Util.say "DropboxAccount#ensure_ro_folder called. RO folder already exists, so it's all good!"
    end
    
    return true
  end
  
end
