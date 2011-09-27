assignments = CodeAssignment.find(:all, :conditions => "percentage > 0 AND percentage < 1")
activities = assignments.map{|ca| ca.activity}.uniq!

activities.each do |activity|
  [CodingBudget, CodingBudgetDistrict, CodingBudgetCostCategorization,
    CodingSpend, CodingSpendDistrict, CodingSpendCostCategorization].each do |type|
      activity.update_classified_amount_cache(type)
  end
end