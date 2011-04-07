namespace :robox do
  desc "Submits SyncJobs for all Dropbox RO containers. Use 'ruby script/delayed_job start' to actually run these jobs"
  task :sync_jobs => :environment do
    DropboxResearchObjectContainer.all.each do |c|
      # Only submit a job if no currently pending or running jobs are in the queue
      unless c.current_job_exists?
        sync_job = c.sync_jobs.build
        sync_job.save!
        sync_job.delay.run
      end
    end
  end
end