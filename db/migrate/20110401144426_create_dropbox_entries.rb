class CreateDropboxEntries < ActiveRecord::Migration
  def self.up
    create_table :dropbox_entries do |t|
      t.belongs_to :research_object, :null => false
      t.string :path, :null => false
      t.string :entry_type_code, :null => false
      t.integer :parent_id
      t.string :hash
      t.integer :revision, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :dropbox_entries
  end
end
