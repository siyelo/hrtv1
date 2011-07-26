Activity.reset_column_information

activities     = Activity.only_simple.all
activity_total = activities.length

activities.each_with_index do |activity, index|
  puts "Updating classifications for activity: #{activity.id} | #{index + 1}/#{activity_total}: "
  activity.coding_budget_valid          = CodingTree.new(activity, CodingBudget).valid?
  activity.coding_budget_cc_valid       = CodingTree.new(activity, CodingBudgetCostCategorization).valid?
  activity.coding_budget_district_valid = CodingTree.new(activity, CodingBudgetDistrict).valid?

  activity.coding_spend_valid           = CodingTree.new(activity, CodingSpend).valid?
  activity.coding_spend_cc_valid        = CodingTree.new(activity, CodingSpendCostCategorization).valid?
  activity.coding_spend_district_valid  = CodingTree.new(activity, CodingSpendDistrict).valid?
  activity.save(false)
end

