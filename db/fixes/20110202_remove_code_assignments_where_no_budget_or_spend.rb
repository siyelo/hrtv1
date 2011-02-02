
budget_types = [CodingBudget.to_s, CodingBudgetCostCategorization.to_s, CodingBudgetDistrict.to_s]
spend_types = [CodingSpend.to_s, CodingSpendCostCategorization.to_s, CodingSpendDistrict.to_s]

print "Deleting budget code assignments where activity.budget is nil..."
ca11 = CodeAssignment.find(:all, :joins => :activity, :conditions => ['activities.budget IS NULL AND code_assignments.type IN (?)', budget_types])
ca11_total = CodeAssignment.delete_all(["id IN (?)", ca11.map(&:id)])
puts " #{ca11_total} code assignments deleted."

print "Deleting spend code assignments where activity.spend is nil..."
ca12 = CodeAssignment.find(:all, :joins => :activity, :conditions => ['activities.spend IS NULL AND code_assignments.type IN (?)', spend_types])
ca12_total = CodeAssignment.delete_all(["id IN (?)", ca12.map(&:id)])
puts " #{ca12_total} code assignments deleted."

print "Deleting budget code assignments where activity.budget is nil..."
ca21 = CodeAssignment.find(:all, :joins => :activity, :conditions => ['activities.budget = 0 AND code_assignments.type IN (?)', budget_types])
ca21_total = CodeAssignment.delete_all(["id IN (?)", ca21.map(&:id)])
puts " #{ca21_total} code assignments deleted."

print "Deleting spend code assignments where activity.spend is nil..."
ca22 = CodeAssignment.find(:all, :joins => :activity, :conditions => ['activities.spend = 0 AND code_assignments.type IN (?)', spend_types])
ca22_total = CodeAssignment.delete_all(["id IN (?)", ca22.map(&:id)])
puts " #{ca22_total} code assignments deleted."

