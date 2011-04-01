class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :dropbox_accounts, :user_id
    add_index :dropbox_accounts, :dropbox_user_id
    
    add_index :sync_jobs, :dropbox_account_id
    add_index :sync_jobs, [ :dropbox_account_id, :status_code ]
    
    add_index :research_objects, :dropbox_account_id
    add_index :research_objects, [ :dropbox_account_id, :name ], :unique => true
    
    add_index :dropbox_entries, :research_object_id
    add_index :dropbox_entries, [ :research_object_id, :entry_type_code ]
    add_index :dropbox_entries, :parent_id
  end

  def self.down
    remove_index :dropbox_accounts, :user_id
    remove_index :dropbox_accounts, :dropbox_user_id
    
    remove_index :sync_jobs, :dropbox_account_id
    remove_index :sync_jobs, [ :dropbox_account_id, :status_code ]
    
    remove_index :research_objects, :dropbox_account_id
    remove_index :research_objects, [ :dropbox_account_id, :name ]
    
    remove_index :dropbox_entries, :research_object_id
    remove_index :dropbox_entries, [ :research_object_id, :entry_type_code ]
    remove_index :dropbox_entries, :parent_id
  end
end
