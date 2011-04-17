class AddNameToDropboxEntries < ActiveRecord::Migration
  def self.up
    add_column :dropbox_entries, :name, :string, :null => false, :default => '(unknown)'
  end

  def self.down
    remove_column :dropbox_entries, :name
  end
end
