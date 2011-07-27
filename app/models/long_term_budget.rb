class LongTermBudget < ActiveRecord::Base

  ### Associations
  belongs_to :organization
  has_many   :budget_entries

  ### Validations
  validates_presence_of :organization_id, :year
end
