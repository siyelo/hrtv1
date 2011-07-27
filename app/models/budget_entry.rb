class BudgetEntry < ActiveRecord::Base

  ### Associations
  belongs_to :long_term_budget
  belongs_to :purpose

  ### Validations
  validates_presence_of :long_term_budget_id, :purpose_id, :year, :amount
end
