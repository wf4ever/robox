# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :dropbox_entry, :default_strategy => :build do |f|
  f.association :research_object, :factory => :research_object
  f.sequence(:path) { |n| "/entry_#{n}" }
  f.revision 1
end

Factory.define :file_dropbox_entry, 
    :parent => :dropbox_entry do |f| 
  f.entry_type :file
end

Factory.define :directory_dropbox_entry, 
    :parent => :dropbox_entry do |f| 
  f.entry_type :directory
  f.sequence(:hash) { |n| "97FDEA6D5A79A7DE123FBCDBB#{n}" }
end

Factory.define :manifest_dropbox_entry, 
    :parent => :dropbox_entry do |f| 
  f.entry_type :manifest
end

Factory.define :dropbox_entry_with_parent, 
    :parent => :dropbox_entry, 
    :default_strategy => :build do |f| 
  f.association :parent, :factory => :directory_dropbox_entry
end