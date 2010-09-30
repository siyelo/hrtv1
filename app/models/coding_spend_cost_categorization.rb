class CodingSpendCostCategorization < SpendCodeAssignment

  def self.available_codes(activity = nil)
    CostCategory.roots
  end
end
