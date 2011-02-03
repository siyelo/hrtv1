require 'fastercsv'

#activities = [Activity.find(7312)]
activities = Activity.only_simple.find(:all, :conditions => "id < 1000")
#activities = Activity.only_simple.all
total = activities.length

def b(bool)
  bool ? 'yes' : 'no'
end

csv = FasterCSV.generate do |csv|
  # header
  row = ['Activity id', 'Activity name',
         'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization',
         'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization']
  csv << row


  # data
  activities.each_with_index do |activity, index|
    puts "Checking activity with id: #{activity.id} | #{index + 1}/#{total}"

    row = []
    row << activity.id
    row << activity.name
    row << b(CodingTree.new(activity, CodingBudget).valid?)
    row << b(CodingTree.new(activity, CodingBudgetDistrict).valid?)
    row << b(CodingTree.new(activity, CodingBudgetCostCategorization).valid?)
    row << b(CodingTree.new(activity, CodingSpend).valid?)
    row << b(CodingTree.new(activity, CodingSpendDistrict).valid?)
    row << b(CodingTree.new(activity, CodingSpendCostCategorization).valid?)
    csv << row
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'code_assignments_check.csv'), 'w') do |file|
  file.puts csv
end

