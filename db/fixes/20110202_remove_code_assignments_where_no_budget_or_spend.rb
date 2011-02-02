budget_types = [CodingBudget, CodingBudgetCostCategorization, CodingBudgetDistrict]
spend_types = [CodingSpend, CodingSpendCostCategorization, CodingSpendDistrict]

puts "Deleting budget code assignments where activity.budget is nil..."
activities = Activity.find(:all, :conditions => {:budget => nil})
activities_total = activities.length
ca_total = 0
activities.each_with_index do |activity, index|
  puts "Processing activity with id #{activity.id} :: #{index + 1}/#{activities_total}"
  budget_types.each do |type|
    total = CodeAssignment.delete_all(['activity_id = ? AND code_assignments.type = ?', activity.id, type.to_s])
    activity.update_classified_amount_cache(type) if total > 0
    ca_total += total
  end
end
puts " #{ca_total} code assignments deleted."

puts "Deleting budget code assignments where activity.budget is 0..."
activities = Activity.find(:all, :conditions => {:budget => 0})
activities_total = activities.length
ca_total = 0
activities.each_with_index do |activity, index|
  puts "Processing activity with id #{activity.id} :: #{index + 1}/#{activities_total}"
  budget_types.each do |type|
    total = CodeAssignment.delete_all(['activity_id = ? AND code_assignments.type = ?', activity.id, type.to_s])
    activity.update_classified_amount_cache(type) if total > 0
    ca_total += total
  end
end
puts " #{ca_total} code assignments deleted."

puts "Deleting spend code assignments where activity.spend is nil..."
activities = Activity.find(:all, :conditions => {:spend => nil})
activities_total = activities.length
ca_total = 0
activities.each_with_index do |activity, index|
  puts "Processing activity with id #{activity.id} :: #{index + 1}/#{activities_total}"
  spend_types.each do |type|
    total = CodeAssignment.delete_all(['activity_id = ? AND code_assignments.type = ?', activity.id, type.to_s])
    activity.update_classified_amount_cache(type) if total > 0
    ca_total += total
  end
end
puts " #{ca_total} code assignments deleted."

puts "Deleting spend code assignments where activity.spend is 0..."
activities = Activity.find(:all, :conditions => {:spend => 0})
activities_total = activities.length
ca_total = 0
activities.each_with_index do |activity, index|
  puts "Processing activity with id #{activity.id} :: #{index + 1}/#{activities_total}"
  spend_types.each do |type|
    total = CodeAssignment.delete_all(['activity_id = ? AND code_assignments.type = ? ', activity.id, type.to_s])
    activity.update_classified_amount_cache(type) if total > 0
    ca_total += total
  end
end
puts " #{ca_total} code assignments deleted."
