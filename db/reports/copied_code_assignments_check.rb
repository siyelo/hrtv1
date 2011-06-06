require 'fastercsv'
require 'set'

def same?(cas1, cas2)
  #puts cas1.map{|ca| [ca.code_id, ca.amount, ca.percentage]}.to_set.to_a if cas1.first.try(:activity).try(:id) == 908
  #puts cas2.map{|ca| [ca.code_id, ca.amount, ca.percentage]}.to_set.to_a if cas1.first.try(:activity).try(:id) == 908
  #raise '908' if cas1.first.try(:activity).try(:id) == 908
  # this doesn't work correctly for some reason
  cas1.map{|ca| [ca.code_id, ca.cached_amount ]}.to_set ==
    cas2.map{|ca| [ca.code_id, ca.cached_amount ]}.to_set && cas2.size > 0

end

activities = Activity.all
#activities = Activity.find(:all, :conditions => "spend = 0 OR spend IS NULL")
#activities = [Activity.find(7312)]

total = activities.length

csv = FasterCSV.generate do |csv|
  # header
  row = ["index", "id", "name", "currency", "spent", "budget", "Same assignments?", "Same district assignments?", "Same cost_category assignments?"]
  csv << row


  # data
  activities.each_with_index do |activity, index|
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

    # print only the code assignments if they are same and if they are not empty
    if ((same_codings || same_district_codings || same_cost_category_codings) &&
       (cas12.present? || cas22.present? || cas32.present?))
      row = []
      row << index
      row << activity.id
      row << activity.name
      row << activity.currency
      row << activity.spend
      row << activity.budget
      row << (same_codings ? 'Yes' : 'No')
      row << (same_district_codings ? 'Yes' : 'No')
      row << (same_cost_category_codings ? 'Yes' : 'No')

      csv << row
    end

  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'copied_code_assignments_check.csv'), 'w') do |file|
  file.puts csv
end
