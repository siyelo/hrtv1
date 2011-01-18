class District < ActiveRecord::Base

  # Associations
  belongs_to :old_location, :class_name => "Location"

  # Validations
  validates_presence_of :name, :population
end
