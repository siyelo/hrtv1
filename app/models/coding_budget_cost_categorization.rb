class CodingBudgetCostCategorization < BudgetCodeAssignment

  def self.available_codes(activity = nil)
    CostCategory.roots
  end
end





# == Schema Information
#
# Table name: code_assignments
#
#  id                  :integer         primary key
#  activity_id         :integer         indexed => [code_id, type]
#  code_id             :integer         indexed, indexed => [activity_id, type]
#  amount              :decimal(, )
#  type                :string(255)     indexed => [activity_id, code_id]
#  percentage          :decimal(, )
#  cached_amount       :decimal(, )     default(0.0)
#  sum_of_children     :decimal(, )     default(0.0)
#  new_amount          :integer         default(0), not null
#  new_amount_currency :string(255)
#

