class AddErrorMessageAndStatsToSyncJob < ActiveRecord::Migration
  def self.up
    change_table :sync_jobs do |t|
      t.string :error_message
      t.text :stats, :limit => 1.megabyte
    end
  end

  def self.down
    change_table :sync_jobs do |t|
      t.remove :error_message, :stats
    end
  end
end
