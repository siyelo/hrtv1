class CodingBudgetCostCategorization < BudgetCodeAssignment

  def self.available_codes(activity = nil)
    CostCategory.roots
  end
end
