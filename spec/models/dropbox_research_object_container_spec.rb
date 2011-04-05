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

require 'spec_helper'

describe DropboxResearchObjectContainer do
  pending "add some examples to (or delete) #{__FILE__}"
end
