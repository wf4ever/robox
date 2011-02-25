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
