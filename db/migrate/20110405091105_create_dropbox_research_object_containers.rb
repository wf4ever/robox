class CreateDropboxResearchObjectContainers < ActiveRecord::Migration
  def self.up
    create_table :dropbox_research_object_containers do |t|
      t.belongs_to :dropbox_account
      t.string :path, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dropbox_research_object_containers
  end
end
