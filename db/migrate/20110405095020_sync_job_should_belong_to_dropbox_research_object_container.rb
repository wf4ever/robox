class SyncJobShouldBelongToDropboxResearchObjectContainer < ActiveRecord::Migration
  def self.up
    remove_index :sync_jobs, :dropbox_account_id
    remove_index :sync_jobs, [ :dropbox_account_id, :status_code ]
    
    change_table :sync_jobs do |t|
      t.remove :dropbox_account_id
      t.belongs_to :dropbox_research_object_container
    end
    
    #add_index :sync_jobs, :dropbox_research_object_container_id
    #add_index :sync_jobs, [ :dropbox_research_object_container_id, :status_code ], :name => "index_sync_jobs_on_dbox_ro_container_id_and_status"
  end

  def self.down
    #remove_index :sync_jobs, :dropbox_research_object_container_id
    #remove_index :sync_jobs, :name => "index_sync_jobs_on_dbox_ro_container_id_and_status"
    
    change_table :sync_jobs do |t|
      t.remove :dropbox_research_object_container
      t.belongs_to :dropbox_account_id
    end
    
    add_index :sync_jobs, :dropbox_account_id
    add_index :sync_jobs, [ :dropbox_account_id, :status_code ]
  end
end
