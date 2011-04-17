class AddRosrsVersionUriToResearchObjects < ActiveRecord::Migration
  def self.up
    add_column :research_objects, :rosrs_version_uri, :string
  end

  def self.down
    remove_column :research_objects, :rosrs_version_uri
  end
end
