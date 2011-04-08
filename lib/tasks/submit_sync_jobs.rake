namespace :robox do
  desc "Submits SyncJobs for all Dropbox RO containers. Use 'ruby script/delayed_job start' to actually run these jobs"
  task :sync_jobs => :environment do
    DropboxResearchObjectContainer.all.each do |c|

      # If there any pending jobs that haven't run for
      # a certain period of time, then resubmit them
      pending_jobs = c.pending_jobs_to_resubmit

      if pending_jobs.blank?
        # Only submit a job if no currently pending or running jobs are in the queue
        unless c.current_job_exists?
          sync_job = c.sync_jobs.build
          sync_job.save!
          sync_job.delay.run
          Util.say "Submitted new SyncJob for DropboxResearchObjectContainer with ID '#{c.id}'"
        end
      else
        # Only resubmit the last pending job
        pending_jobs.first.delay.run
      end
    end
  end
end