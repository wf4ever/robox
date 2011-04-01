# == Schema Information
# Schema version: 20110401105537
#
# Table name: sync_jobs
#
#  id                 :integer(4)      not null, primary key
#  dropbox_account_id :integer(4)      not null
#  started_at         :datetime
#  finished_at        :datetime
#  status_code        :string(255)     not null
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec_helper'

describe SyncJob do
  
  describe "when creating" do
    
    it "should have an appropriate initial state" do
      job = Factory.build(:sync_job)
      
      job.pending?.should be_true
      job.running?.should_not be_true
      job.failed?.should_not be_true
      job.success?.should_not be_true
      
      job.started?.should_not be_true
      job.finished?.should_not be_true
    end
    
  end

end
