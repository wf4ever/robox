# == Schema Information
# Schema version: 20110401144426
#
# Table name: research_objects
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)     not null
#  dropbox_account_id :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
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
