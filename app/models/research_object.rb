# == Schema Information
# Schema version: 20110401144426
#
# Table name: research_objects
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)     not null
#  dropbox_account_id :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#

class ResearchObject < ActiveRecord::Base
  
  include DatabaseValidation
  
  attr_accessible :name,
                  :dropbox_account_id
  
  validates :dropbox_account,
            :existence => true
  
  belongs_to :dropbox_account
  
  has_many :dropbox_entries
  
  has_many :children,
           :class_name => "DropboxEntry",
           :foreign_key => "research_object_id",
           :conditions => { :parent_id => nil }

end
