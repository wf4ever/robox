class AddWorkspacePasswordToDropboxAccount < ActiveRecord::Migration
  def self.up
    add_column :dropbox_accounts, :workspace_password, :string
  end

  def self.down
    remove_column :dropbox_accounts, :workspace_password
  end
end
