class CreateDropboxAccounts < ActiveRecord::Migration
  def self.up
    create_table :dropbox_accounts do |t|
      t.references :user, :null => false
      t.string :dropbox_user_id, :null => false
      t.string :access_token, :null => false
      t.string :access_secret, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dropbox_accounts
  end
end
