class FundingSource < ActiveRecord::Base

  ### Associations
  belongs_to :activity
  belongs_to :funding_flow

  ### Validations
  validates_presence_of :funding_flow_id

end


# == Schema Information
#
# Table name: funding_sources
#
#  id              :integer         not null, primary key
#  activity_id     :integer
#  funding_flow_id :integer
#  spend           :integer(10)
#  budget          :integer(10)
#  created_at      :datetime
#  updated_at      :datetime
#

