class RemoveRoFolderAndWorkspaceFromDropboxAccounts < ActiveRecord::Migration
  def self.up
    remove_column :dropbox_accounts, :ro_folder
    remove_column :dropbox_accounts, :workspace_password
  end

  def self.down
    add_column :dropbox_accounts, :ro_folder, :string
    add_column :dropbox_accounts, :workspace_password, :string
  end
end
