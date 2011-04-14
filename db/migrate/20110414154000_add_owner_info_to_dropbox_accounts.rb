class AddOwnerInfoToDropboxAccounts < ActiveRecord::Migration
  def self.up
    add_column :dropbox_accounts, :owner_name, :string, :null => false, :default => "Unknown"
    add_column :dropbox_accounts, :owner_email, :string, :null => false, :default => "unknown@example.com"
  end

  def self.down
    remove_column :dropbox_accounts, :owner_name
    remove_column :dropbox_accounts, :owner_email
  end
end
