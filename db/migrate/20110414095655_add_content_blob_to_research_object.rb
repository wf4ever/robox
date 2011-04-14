class AddContentBlobToResearchObject < ActiveRecord::Migration
  def self.up
    add_column :research_objects, :content_blob_id, :integer
  end

  def self.down
    remove_column :research_objects, :content_blob_id
  end
end
