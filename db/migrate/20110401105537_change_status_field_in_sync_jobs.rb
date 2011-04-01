class ChangeStatusFieldInSyncJobs < ActiveRecord::Migration
  def self.up
    rename_column :sync_jobs, :status, :status_code
  end

  def self.down
    rename_column :sync_jobs, :status_code, :status
  end
end
