Factory.define :sync_job do |c|
  c.association :dropbox_account, :factory => :dropbox_account
end