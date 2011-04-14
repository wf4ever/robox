class CreateContentBlobs < ActiveRecord::Migration
  def self.up
    create_table :content_blobs do |t|
      t.binary :content, :limit => 10.megabytes, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :content_blobs
  end
end
