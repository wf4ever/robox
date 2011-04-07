class RemoveStatsFromSyncJobs < ActiveRecord::Migration
  def self.up
    remove_column :sync_jobs, :stats
  end

  def self.down
    add_column :sync_jobs, :stats, :text, :limit => 1.megabyte
  end
end
