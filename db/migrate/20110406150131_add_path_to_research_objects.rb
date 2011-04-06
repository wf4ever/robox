class AddPathToResearchObjects < ActiveRecord::Migration
  def self.up
    add_column :research_objects, :path, :string, :null => false, :default => "--unknown--"
  end

  def self.down
    remove_column :research_objects, :path
  end
end
