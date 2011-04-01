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

require 'spec_helper'

describe DropboxAccount do
  
  describe "#setup_user" do
    
    it "should build and create an associated user successfully" do
      acc = Factory.build(:dropbox_account, :user => nil)
      acc_info = Hashie::Mash.new({
        :uid => acc.dropbox_user_id,
        :email => "dropbox@example.org",
        :display_name => "dropbox user x"
      })
      
      acc.setup_user! acc_info
      acc.user.should_not be_nil

      expect { acc.save! }.to_not raise_error
      
      acc_again = DropboxAccount.find(acc.id)
      acc_again.user.should_not be_nil
      acc_again.user.email.should == "dropbox@example.org"
      acc_again.user.name.should == "dropbox user x" 
    end
    
  end
  
end
