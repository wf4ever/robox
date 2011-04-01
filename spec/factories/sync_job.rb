Factory.define :sync_job do |f|
  f.association :dropbox_account, :factory => :dropbox_account
end