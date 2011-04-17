class ContentBlob < ActiveRecord::Base

  include DatabaseValidation

  attr_accessible :content

end
