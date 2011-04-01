class CreateResearchObjects < ActiveRecord::Migration
  def self.up
    create_table :research_objects do |t|
      t.string :name, :null => false
      t.belongs_to :dropbox_account

      t.timestamps
    end
  end

  def self.down
    drop_table :research_objects
  end
end
