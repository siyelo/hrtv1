class FundingSource < ActiveRecord::Base

  ### Associations
  belongs_to :activity
  belongs_to :funding_flow

  ### Validations
  validates_presence_of :funding_flow_id

end
