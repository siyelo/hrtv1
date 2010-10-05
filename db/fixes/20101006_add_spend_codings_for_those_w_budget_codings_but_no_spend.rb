Activity.all.each do |a|
  to_move_to_if_missing = { CodingBudget => CodingSpend,
    CodingBudgetCostCategorization => CodingSpendCostCategorization,
    CodingBudgetDistrict => CodingSpendDistrict}
  
end
