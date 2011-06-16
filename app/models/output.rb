class Output < ActiveRecord::Base

  ### Associations
  belongs_to :activity

  ### Validations
  validates_presence_of :description
end
