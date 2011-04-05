# == Schema Information
# Schema version: 20110405093135
#
# Table name: dropbox_entries
#
#  id                 :integer(4)      not null, primary key
#  research_object_id :integer(4)      not null
#  path               :string(255)     not null
#  entry_type_code    :string(255)     not null
#  parent_id          :integer(4)
#  hash               :string(255)
#  revision           :integer(4)      not null
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_dropbox_entries_on_research_object_id                      (research_object_id)
#  index_dropbox_entries_on_research_object_id_and_entry_type_code  (research_object_id,entry_type_code)
#  index_dropbox_entries_on_parent_id                               (parent_id)
#

class DropboxEntry < ActiveRecord::Base
  
  as_enum :entry_type, 
          { :file => "FILE", 
            :directory => "DIRECTORY",
            :manifest => "MANIFEST" },
          :upcase => true,
          :column => 'entry_type_code'
          
  include DatabaseValidation
  
  validates_as_enum :entry_type
  
  attr_accessible :research_object_id,
                  :path,
                  :parent_id,
                  :hash,
                  :revision
  
  validates :research_object,
            :existence => true
            
  validates :parent,
            :existence => { :allow_nil => true, :both => false }
  
  validate :check_entry_type_rules
  
  validate :check_parent
  
  belongs_to :research_object
  
  belongs_to :parent,
             :class_name => "DropboxEntry",
             :foreign_key => "parent_id"
  
  protected
  
  def check_entry_type_rules
    if entry_type == :directory
      # Directories MUST have a hash specified
      errors.add(:hash, "can't be blank for a directory entry") if hash.blank?
    elsif entry_type == :manifest
      # Manifests CANNOT have a parent entry
      errors.add(:parent, "is not allowed for a manifest entry") unless parent.nil?
    end  
  end
  
  # Parent can only be a directory
  def check_parent
    unless parent.nil? || parent.directory?
      errors.add(:parent, "has to be a directory entry")
    end
  end
  
end
