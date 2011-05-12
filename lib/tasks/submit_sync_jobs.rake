namespace :robox do
  desc "Submits SyncJobs for all Dropbox RO containers. Use 'ruby script/delayed_job start' to actually run these jobs"
  task :sync_jobs => :environment do
    DropboxResearchObjectContainer.all.each do |c|
      c.submit_sync_job
    end
  end
end