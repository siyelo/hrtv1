class Target < ActiveRecord::Base

  ### Associations
  belongs_to :activity

  ### Validations
  validates_presence_of :description

  ### Constants
  HUMANIZED_ATTRIBUTES = { :description => "Target description" }

  ### Class Methods
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
end


# == Schema Information
#
# Table name: targets
#
#  id          :integer         not null, primary key
#  activity_id :integer
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

