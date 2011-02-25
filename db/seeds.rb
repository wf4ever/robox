# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
# Setup initial user so we can get in
ActiveRecord::Base.transaction do
  if User.count == 0 && Role.count == 0
  	user = User.new :name => "Admin", :email => "admin@example.org", :password => "password", :password_confirmation => "password"
    user.id = 1
    user.save!
    user.confirmed_at = user.confirmation_sent_at
    user.save!
    
    role1 = Role.new :name => 'Admin'
    role1.id = 1
    role1.save!
    
    role2 = Role.new :name => 'Member'
    role2.id = 2
    role2.save!
    
    user.role_ids = [1,2]
    user.save!
  end
end
