# == Schema Information
# Schema version: 20110406150131
#
# Table name: research_objects
#
#  id                                   :integer(4)      not null, primary key
#  name                                 :string(255)     not null
#  created_at                           :datetime
#  updated_at                           :datetime
#  dropbox_research_object_container_id :integer(4)
#  path                                 :string(255)     default("--unknown--"), not null
#
# Indexes
#
#  index_research_objects_on_dbox_ro_container_id_and_name         (dropbox_research_object_container_id,name) UNIQUE
#  index_research_objects_on_dropbox_research_object_container_id  (dropbox_research_object_container_id)
#

class ResearchObject < ActiveRecord::Base
  
  include DatabaseValidation
  
  attr_accessible :name,
                  :path,
                  :dropbox_research_object_container_id
  
  validates :ro_container,
            :existence => true
  
  belongs_to :ro_container,
             :class_name => "DropboxResearchObjectContainer",
             :foreign_key => "dropbox_research_object_container_id"
  
  has_many :dropbox_entries,
           :dependent => :destroy
  
  has_many :children,
           :class_name => "DropboxEntry",
           :foreign_key => "research_object_id",
           :conditions => { :parent_id => nil }

  belongs_to :content_blob,
              :autosave => true

  def manifest
    self.content_blob.try(:content)
  end

  def manifest=(content)
    self.build_content_blob
    self.content_blob.content = content
  end

end
