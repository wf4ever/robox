# == Schema Information
# Schema version: 20110401105537
#
# Table name: roles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  attr_accessible :name

  def self.sanitize role
    role.to_s.humanize.split(' ').each{ |word| word.capitalize! }.join(' ')
  end
end
