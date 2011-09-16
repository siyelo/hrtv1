class Output < ActiveRecord::Base

  ### Associations
  belongs_to :activity

  ### Validations
  validates_presence_of :description
  validates_length_of :description, :maximum => 250

  ### Constants
  HUMANIZED_ATTRIBUTES = { :description => "Output description" }

  ### Class Methods
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
end

# == Schema Information
#
# Table name: outputs
#
#  id          :integer         not null, primary key
#  activity_id :integer
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

