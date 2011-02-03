budget_types = [CodingBudget, CodingBudgetCostCategorization, CodingBudgetDistrict]
spend_types = [CodingSpend, CodingSpendCostCategorization, CodingSpendDistrict]

puts "Deleting budget code assignments where activity.budget is nil..."
activities = Activity.only_simple.find(:all, :conditions => {:budget => nil})
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
activities = Activity.only_simple.find(:all, :conditions => {:spend => nil})
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


# CF: https://rwandaonrails.campfirenow.com/room/313278/transcript/2011/02/02
#
# dalibor, commits look good
# 1 thing: lets not delete code assignments when spend or budget is 0, lets just set any amounts to nil, leave percentages
# otherwise we will sabotage that "put percentages in budget assigns and copied them over" case


puts "Setting amounts to nil for budget code assignments where activity.budget is 0..."
activities = Activity.only_simple.find(:all, :conditions => {:budget => 0})
activities_total = activities.length
ca_total = 0
activities.each_with_index do |activity, index|
  puts "Processing activity with id #{activity.id} :: #{index + 1}/#{activities_total}"
  budget_types.each do |type|
    code_assignments = CodeAssignment.find(:all, :conditions => ['activity_id = ? AND code_assignments.type = ?', activity.id, type.to_s])
    total = code_assignments.length
    code_assignments.each do |code_assignment|
      code_assignment.amount = nil
      code_assignment.cached_amount = nil
      code_assignment.sum_of_children = nil
      code_assignment.save!
    end
    activity.update_classified_amount_cache(type) if total > 0
    ca_total += total
  end
end
puts " #{ca_total} code assignments updated."

puts "Setting amounts to nil for spend code assignments where activity.spend is 0..."
activities = Activity.only_simple.find(:all, :conditions => {:spend => 0})
activities_total = activities.length
ca_total = 0
activities.each_with_index do |activity, index|
  puts "Processing activity with id #{activity.id} :: #{index + 1}/#{activities_total}"
  spend_types.each do |type|
    code_assignments = CodeAssignment.find(:all, :conditions => ['activity_id = ? AND code_assignments.type = ?', activity.id, type.to_s])
    total = code_assignments.length
    code_assignments.each do |code_assignment|
      code_assignment.amount = nil
      code_assignment.cached_amount = nil
      code_assignment.sum_of_children = nil
      code_assignment.save!
    end
    activity.update_classified_amount_cache(type) if total > 0
    ca_total += total
  end
end
puts " #{ca_total} code assignments updated."
