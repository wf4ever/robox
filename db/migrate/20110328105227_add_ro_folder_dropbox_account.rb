class AddRoFolderDropboxAccount < ActiveRecord::Migration
  def self.up
    add_column :dropbox_accounts, :ro_folder, :string
  end

  def self.down
    remove_column :dropbox_accounts, :ro_folder
  end
end
