require 'fastercsv'

#activities = [Activity.find(7312)]
#activities = Activity.only_simple.find(:all, :conditions => "id < 1000")
activities = Activity.only_simple.all
total = activities.length

def invalid(bool)
  bool ? '' : 'invalid'
end

csv = FasterCSV.generate do |csv|
  # header
  row = ['Activity id', 'Activity name',
         'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization',
         'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization',
         'Organization ID', 'Organization Name', 'User emails']
  csv << row


  # data
  activities.each_with_index do |activity, index|
    puts "Checking activity with id: #{activity.id} | #{index + 1}/#{total}"

    valid1 = CodingTree.new(activity, CodingBudget).valid?
    valid2 = CodingTree.new(activity, CodingBudgetDistrict).valid?
    valid3 = CodingTree.new(activity, CodingBudgetCostCategorization).valid?
    valid4 = CodingTree.new(activity, CodingSpend).valid?
    valid5 = CodingTree.new(activity, CodingSpendDistrict).valid?
    valid6 = CodingTree.new(activity, CodingSpendCostCategorization).valid?

    # if there is one invalid coding, add it to the report
    if (!valid1 || !valid2 || !valid3 || !valid4 || !valid5 || !valid6)
      row = []
      row << activity.id
      row << activity.name
      row << invalid(valid1)
      row << invalid(valid2)
      row << invalid(valid3)
      row << invalid(valid4)
      row << invalid(valid5)
      row << invalid(valid6)
      row << activity.data_response.organization.id
      row << activity.data_response.organization.name
      row << activity.data_response.organization.users.map{|u| u.email}.join(', ')
      csv << row
    end
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'invalid_code_assignments.csv'), 'w') do |file|
  file.puts csv
end

