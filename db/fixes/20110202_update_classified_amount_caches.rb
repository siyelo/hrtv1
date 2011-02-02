ca_types = [CodingBudget, CodingBudgetCostCategorization, CodingBudgetDistrict,
            CodingSpend, CodingSpendCostCategorization, CodingSpendDistrict]
#activities = [Activity.find(7312)] # DEBUG ONLY
activities = Activity.only_simple.all
total = activities.length
activities.each_with_index do |activity, index|
  puts "Updating activity id: #{activity.id}, :: #{index + 1}/#{total}"
  ca_types.each do |type|
    activity.update_classified_amount_cache(type)
  end
end
