class Target < ActiveRecord::Base

  ### Associations
  belongs_to :activity

  ### Validations
  validates_presence_of :description
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

