class ResearchObjectShouldBelongToDropboxResearchObjectContainer < ActiveRecord::Migration
  def self.up
    remove_index :research_objects, :dropbox_account_id
    remove_index :research_objects, [ :dropbox_account_id, :name ]
    
    change_table :research_objects do |t|
      t.remove :dropbox_account_id
      t.belongs_to :dropbox_research_object_container
    end
    
    add_index :research_objects, :dropbox_research_object_container_id
    add_index :research_objects, [ :dropbox_research_object_container_id, :name ], :name => "index_research_objects_on_dbox_ro_container_id_and_name", :unique => true
  end

  def self.down
    remove_index :research_objects, :dropbox_research_object_container_id
    remove_index :research_objects, [ :dropbox_research_object_container_id, :name ], :name => "index_research_objects_on_dbox_ro_container_id_and_name"
    
    change_table :research_objects do |t|
      t.remove :dropbox_research_object_container
      t.belongs_to :dropbox_account_id
    end
    
    add_index :research_objects, :dropbox_account_id
    add_index :research_objects, [ :dropbox_account_id, :name ], :unique => true
  end
end
