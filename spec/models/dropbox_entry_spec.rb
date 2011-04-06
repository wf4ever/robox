# == Schema Information
# Schema version: 20110405093135
#
# Table name: dropbox_entries
#
#  id                 :integer(4)      not null, primary key
#  research_object_id :integer(4)      not null
#  path               :string(255)     not null
#  entry_type_code    :string(255)     not null
#  parent_id          :integer(4)
#  hash               :string(255)
#  revision           :integer(4)      not null
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_dropbox_entries_on_research_object_id                      (research_object_id)
#  index_dropbox_entries_on_research_object_id_and_entry_type_code  (research_object_id,entry_type_code)
#  index_dropbox_entries_on_parent_id                               (parent_id)
#

require 'spec_helper'

describe DropboxEntry do
  
  describe "#create" do
    
    it "should be able to create valid records" do
      file = Factory.build(:file_dropbox_entry)
      expect { file.save! }.to_not raise_error
      
      dir = Factory.build(:directory_dropbox_entry)
      expect { dir.save! }.to_not raise_error
      
      manifest = Factory.build(:manifest_dropbox_entry)
      expect { manifest.save! }.to_not raise_error
    end
    
  end
  
  it "should fail validation when parent is not a directory" do
    entry = Factory.build(:file_dropbox_entry)
    entry.parent = Factory.create(:file_dropbox_entry)
    
    entry.parent.should_not be_nil
    entry.should have(1).error_on(:parent)
  end
  
  it "should fail validation when a directory has no hash" do
    entry = Factory.build(:dropbox_entry)
    entry.entry_type = :directory
    
    entry.should have(1).error_on(:hash)
  end
  
  it "should fail validation when a manifest has a parent" do 
    entry = Factory.build(:manifest_dropbox_entry)
    entry.parent = Factory.create(:directory_dropbox_entry)
    
    entry.parent.should_not be_nil
    entry.should have(1).error_on(:parent)
  end


  describe "#children" do

    it "should only contain direct children" do
      dir1 = Factory.create(:directory_dropbox_entry)
      dir1.children(true).should be_empty
      file1 = Factory.create(:file_dropbox_entry, :parent=>dir1)
      dir1.children(true).should have_exactly(1).items

      dir2 = Factory.create(:directory_dropbox_entry, :parent =>dir1)
      dir1.children(true).should have_exactly(2).items
      dir2.children(true).should be_empty
      file2 = Factory.create(:file_dropbox_entry, :parent=>dir2)
      dir1.children(true).should have_exactly(2).items
      dir2.children(true).should have_exactly(1).items

      
      file3 = Factory.build(:file_dropbox_entry)
      dir2.children << file3
      file3.parent.should == dir2
      dir2.children(true).should have_exactly(2).items

    end
  end
  
end
