activities     = Activity.all
activity_total = activities.length

activities.each_with_index do |activity, index|
  print "Update cached Coding<blah>_amount fields of activity with id: #{activity.id} | #{index + 1}/#{activity_total}: "

  [CodingBudget,CodingBudgetCostCategorization,CodingBudgetDistrict,CodingSpend,CodingSpendCostCategorization,CodingSpendDistrict].each do |type|
    activity.update_classified_amount_cache(type)
    print "."
  end
  print "\n"
end
puts "Activities cache update done..."
