class ErrorMessageAsBlob < ActiveRecord::Migration
  def self.up
    change_column :sync_jobs, :error_message, :text, :limit => 1.megabyte
  end

  def self.down
    change_column :sync_jobs, :error_message, :string
  end
end
