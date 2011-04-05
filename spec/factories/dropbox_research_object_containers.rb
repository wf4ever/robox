# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :dropbox_research_object_container do |f|
  f.association :dropbox_account, :factory => :dropbox_account
  f.sequence(:path) { |n| "ROs/Collection #{n}" }
end

# DIRTY HACK
# Redefine some of the callbacks as they require
# access to external things
class DropboxResearchObjectContainer < ActiveRecord::Base
  protected
  
  def ensure_workspace_exists_in_rosrs
    return true
  end
  
  def ensure_folder_exists_in_dropbox
    return true
  end
  
end