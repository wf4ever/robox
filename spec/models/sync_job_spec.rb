# == Schema Information
# Schema version: 20110401144426
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
#  error_message      :string(255)
#  stats              :text(16777215)
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
      
      job.started_at.should be_nil
      job.finished_at.should be_nil
    end
    
  end
  
  describe "when status is changed" do
    
    it "should update and persist status correctly" do
      job = Factory.build(:sync_job)
      
      job.status = :running
      expect { job.save! }.to_not raise_error
      
      job_again = SyncJob.find(job.id)
      job_again.pending?.should_not be_true
      job_again.running?.should be_true
      job_again.failed?.should_not be_true
      job_again.success?.should_not be_true
    end
    
  end

end
