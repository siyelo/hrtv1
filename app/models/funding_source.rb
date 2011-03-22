class FundingSource < ActiveRecord::Base

  ### Associations
  belongs_to :activity
  belongs_to :funding_flow
end
