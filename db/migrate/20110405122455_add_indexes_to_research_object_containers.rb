class AddIndexesToResearchObjectContainers < ActiveRecord::Migration
  def self.up
    add_index :dropbox_research_object_containers, :dropbox_account_id
    add_index :dropbox_research_object_containers, [ :dropbox_account_id, :path ], :name => "index_research_objects_on_dbox_account_id_and_path", :unique => true
  end

  def self.down
    remove_index :dropbox_research_object_containers, :dropbox_account_id
    remove_index :dropbox_research_object_containers, :name => "index_research_objects_on_dbox_account_id_and_path"
  end
end
