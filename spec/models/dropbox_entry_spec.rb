# == Schema Information
# Schema version: 20110401144426
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
  
end
