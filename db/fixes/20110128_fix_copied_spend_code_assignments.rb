require 'fastercsv'
require 'set'

def same?(cas1, cas2)
  cas1.map{|ca| [ca.code_id, ca.amount, ca.percentage]}.to_set ==
  cas2.map{|ca| [ca.code_id, ca.amount, ca.percentage]}.to_set
end

activities = Activity.all
#activities = [Activity.find(7312)]
total      = activities.length

activities.each_with_index do |activity, index|
  #cas1 = CodeAssignment.with_activity(activity).with_types([CodingBudget.to_s, CodingBudgetDistrict.to_s, CodingBudgetCostCategorization.to_s])
  #cas2 = CodeAssignment.with_activity(activity).with_types([CodingSpend.to_s, CodingSpendDistrict.to_s, CodingSpendCostCategorization.to_s])
  puts "Checking activity with id: #{activity.id} | #{index + 1}/#{total}"

  cas11 = CodeAssignment.with_activity(activity).with_type(CodingBudget.to_s)
  cas12 = CodeAssignment.with_activity(activity).with_type(CodingSpend.to_s)
  cas21 = CodeAssignment.with_activity(activity).with_type(CodingBudgetDistrict.to_s)
  cas22 = CodeAssignment.with_activity(activity).with_type(CodingSpendDistrict.to_s)
  cas31 = CodeAssignment.with_activity(activity).with_type(CodingBudgetCostCategorization.to_s)
  cas32 = CodeAssignment.with_activity(activity).with_type(CodingSpendCostCategorization.to_s)

  same_codings = same?(cas11, cas12)
  same_district_codings = same?(cas21, cas22)
  same_cost_category_codings = same?(cas31, cas32)

  # change only the code assignments if they are same and if they are not empty
  if same_codings && cas12.present?
    CodeAssignment.with_activity(activity).with_type(CodingSpend.to_s).delete_all
    activity.copy_budget_codings_to_spend([CodingBudget.to_s])
  end
  if same_district_codings && cas22.present?
    CodeAssignment.with_activity(activity).with_type(CodingSpendDistrict.to_s).delete_all
    activity.copy_budget_codings_to_spend([CodingBudgetDistrict.to_s])
  end
  if same_cost_category_codings && cas32.present?
    CodeAssignment.with_activity(activity).with_type(CodingSpendCostCategorization.to_s).delete_all
    activity.copy_budget_codings_to_spend([CodingBudgetCostCategorization.to_s])
  end

end
