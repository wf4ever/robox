# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :dropbox_account do |f|
  f.sequence(:dropbox_user_id) { |n| n }
  f.sequence(:access_token) { |n| "access_token_#{n}" }
  f.sequence(:access_secret) { |n| "access_secret_#{n}" }
  f.association :user, :factory => :user
  f.sequence(:owner_name) { |n| "Joe Bloggs #{n}" }
  f.sequence(:owner_email) { |n| "user.#{n}@example.org" }
end