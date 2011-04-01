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
