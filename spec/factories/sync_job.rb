Factory.define :sync_job do |f|
  f.association :ro_container, :factory => :dropbox_research_object_container
end