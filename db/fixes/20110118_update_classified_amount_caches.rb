Activity.all.each_with_index do |a, index|
  puts "Updating activity id: #{a.id}, counter: #{index}"
  if [OtherCost, Activity].include?(a.class)
    [CodingBudget, CodingBudgetCostCategorization, CodingBudgetDistrict,
     CodingSpend, CodingSpendCostCategorization, CodingSpendDistrict].each do |type|
      a.update_classified_amount_cache(type)
    end
  end
end
