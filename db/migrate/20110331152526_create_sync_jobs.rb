class CreateSyncJobs < ActiveRecord::Migration
  def self.up
    create_table :sync_jobs do |t|
      t.belongs_to :dropbox_account, :null => false
      t.datetime :started_at
      t.datetime :finished_at
      t.string :status, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sync_jobs
  end
end
