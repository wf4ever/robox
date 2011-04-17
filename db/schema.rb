# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110417193930) do

  create_table "content_blobs", :force => true do |t|
    t.binary   "content",    :limit => 16777215, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dropbox_accounts", :force => true do |t|
    t.integer  "user_id",                                            :null => false
    t.string   "dropbox_user_id",                                    :null => false
    t.string   "access_token",                                       :null => false
    t.string   "access_secret",                                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_name",      :default => "Unknown",             :null => false
    t.string   "owner_email",     :default => "unknown@example.com", :null => false
  end

  add_index "dropbox_accounts", ["dropbox_user_id"], :name => "index_dropbox_accounts_on_dropbox_user_id"
  add_index "dropbox_accounts", ["user_id"], :name => "index_dropbox_accounts_on_user_id"

  create_table "dropbox_entries", :force => true do |t|
    t.integer  "research_object_id", :null => false
    t.string   "path",               :null => false
    t.string   "entry_type_code",    :null => false
    t.integer  "parent_id"
    t.string   "hash"
    t.integer  "revision",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dropbox_entries", ["parent_id"], :name => "index_dropbox_entries_on_parent_id"
  add_index "dropbox_entries", ["research_object_id", "entry_type_code"], :name => "index_dropbox_entries_on_research_object_id_and_entry_type_code"
  add_index "dropbox_entries", ["research_object_id"], :name => "index_dropbox_entries_on_research_object_id"

  create_table "dropbox_research_object_containers", :force => true do |t|
    t.integer  "dropbox_account_id"
    t.string   "path",               :null => false
    t.string   "workspace_id"
    t.string   "workspace_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dropbox_research_object_containers", ["dropbox_account_id", "path"], :name => "index_research_objects_on_dbox_account_id_and_path", :unique => true
  add_index "dropbox_research_object_containers", ["dropbox_account_id"], :name => "index_dropbox_research_object_containers_on_dropbox_account_id"

  create_table "research_objects", :force => true do |t|
    t.string   "name",                                                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dropbox_research_object_container_id"
    t.string   "path",                                 :default => "--unknown--", :null => false
    t.integer  "content_blob_id"
    t.string   "rosrs_version_uri"
  end

  add_index "research_objects", ["dropbox_research_object_container_id", "name"], :name => "index_research_objects_on_dbox_ro_container_id_and_name", :unique => true
  add_index "research_objects", ["dropbox_research_object_container_id"], :name => "index_research_objects_on_dropbox_research_object_container_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "sync_jobs", :force => true do |t|
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "status_code",                          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "error_message"
    t.integer  "dropbox_research_object_container_id"
  end

  add_index "sync_jobs", ["dropbox_research_object_container_id", "status_code"], :name => "index_sync_jobs_on_dbox_ro_container_id_and_status"
  add_index "sync_jobs", ["dropbox_research_object_container_id"], :name => "index_sync_jobs_on_dropbox_research_object_container_id"

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "cached_slug"
    t.datetime "deleted_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
