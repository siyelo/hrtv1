class BudgetEntry < ActiveRecord::Base

  ### Associations
  belongs_to :long_term_budget
  belongs_to :purpose

  ### Validations
  validates_presence_of :long_term_budget_id, :purpose_id, :year, :amount
end

# == Schema Information
#
# Table name: budget_entries
#
#  id                  :integer         not null, primary key
#  long_term_budget_id :integer
#  purpose_id          :integer
#  year                :integer
#  amount              :decimal(, )
#  created_at          :datetime
#  updated_at          :datetime
#

