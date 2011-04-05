# == Schema Information
# Schema version: 20110405122455
#
# Table name: research_objects
#
#  id                                   :integer(4)      not null, primary key
#  name                                 :string(255)     not null
#  created_at                           :datetime
#  updated_at                           :datetime
#  dropbox_research_object_container_id :integer(4)
#
# Indexes
#
#  index_research_objects_on_dbox_ro_container_id_and_name         (dropbox_research_object_container_id,name) UNIQUE
#  index_research_objects_on_dropbox_research_object_container_id  (dropbox_research_object_container_id)
#

require 'spec_helper'

describe ResearchObject do
  
  describe "#children and #dropbox_entries" do
    
    it "should know the difference between direct children and deeper entries" do
      ro = Factory.create(:research_object)
      
      file1 = Factory.create(:file_dropbox_entry, :research_object => ro)
      dir1 = Factory.create(:directory_dropbox_entry, :research_object => ro)
      manifest = Factory.create(:manifest_dropbox_entry, :research_object => ro)
      
      file2 = Factory.create(:file_dropbox_entry, :research_object => ro, :parent => dir1)
      dir2 = Factory.create(:directory_dropbox_entry, :research_object => ro, :parent => dir1)
      
      ro.children(true).should have_exactly(3).items
      ro.dropbox_entries(true).should have_exactly(5).items
    end
    
  end
  
end
