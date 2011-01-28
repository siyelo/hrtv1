require 'fastercsv'
require 'set'

# delete all spend code assignments where activity spent is 0
# spent classifications are invalid & if you join budget and spent code assignments for a respective type (e.g budgetcodings and spendcodings) and the amounts are equal


def same?(cas1, cas2)
  cas1.map{|ca| [ca.code_id, ca.amount, ca.percentage]}.to_set ==
  cas2.map{|ca| [ca.code_id, ca.amount, ca.percentage]}.to_set
end

activities = Activity.all
#activities = Activity.find(:all, :conditions => "spend = 0 OR spend IS NULL")
#activities = [Activity.find(7312)]

total = activities.length

csv = FasterCSV.generate do |csv|
  # header
  row = ["index", "id", "name", "Same assignments?", "Same district assignments?", "Same cost_category assignments?"]
  csv << row


  # data
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

    # print only the code assignments if there is same and if they are no empty
    if ((same_codings || same_district_codings || same_cost_category_codings) &&
       (cas12.present? || cas22.present? || cas32.present?))
      row = []
      row << index
      row << activity.id
      row << activity.name
      row << (same_codings ? 'Yes' : 'No')
      row << (same_district_codings ? 'Yes' : 'No')
      row << (same_cost_category_codings ? 'Yes' : 'No')

      csv << row
    end

  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'code_assignments_check.csv'), 'w') do |file|
  file.puts csv
end
