# TODO: remove this model and move fields to Code model
class District < ActiveRecord::Base

  # Associations
  belongs_to :old_location, :class_name => "Location"

  # Validations
  validates_presence_of :name, :population
end




# == Schema Information
#
# Table name: districts
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  population      :integer
#  old_location_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

