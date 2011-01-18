Activity.all.each do |a|
  if [OtherCost, Activity].include?(a.class)
    [CodingBudget, CodingBudgetCostCategorization, CodingBudgetDistrict,
     CodingSpend, CodingSpendCostCategorization, CodingSpendDistrict].each do |type|
      puts "Updating activity #{a.id} #{a.description}"
      a.update_classified_amount_cache(type)
    end
  end
end
