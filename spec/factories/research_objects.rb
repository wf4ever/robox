# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :research_object do |f|
  f.sequence(:name) { |n| "research_object_#{n}" }
  f.association :ro_container, :factory => :dropbox_research_object_container
end