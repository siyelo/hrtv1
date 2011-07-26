puts 'Removing duplicate code assignments'

total_deleted = 0
activity_total = Activity.only_simple.count

Activity.only_simple.each_with_index do |activity, i|
#Activity.only_simple.find(:all, :conditions => ["id = ?", 1922]).each_with_index do |activity, i|
  puts "Cleaning code assignments for activity: #{activity.id} | #{i + 1}/#{activity_total}: "

  # order by id to leave the most recent ones

  ['CodingBudget', 'CodingBudgetCostCategorization', 'CodingBudgetDistrict',
   'CodingSpend', 'CodingSpendCostCategorization', 'CodingSpendDistrict'].each do |coding_type|
    code_assignments = activity.code_assignments.with_type(coding_type).find(:all, :order => 'id DESC')

    hash = {}
    delete_ids = []
    code_assignments.each do |ca|
      if hash[ca.code_id]
        delete_ids << ca.id
      else
        hash[ca.code_id] = ca
      end
    end

    if delete_ids.present?
      CodeAssignment.delete_all(['id IN (?)', delete_ids])
      total_deleted += delete_ids.length

      activity.coding_budget_valid          = CodingTree.new(activity, CodingBudget).valid?
      activity.coding_budget_cc_valid       = CodingTree.new(activity, CodingBudgetCostCategorization).valid?
      activity.coding_budget_district_valid = CodingTree.new(activity, CodingBudgetDistrict).valid?

      activity.coding_spend_valid           = CodingTree.new(activity, CodingSpend).valid?
      activity.coding_spend_cc_valid        = CodingTree.new(activity, CodingSpendCostCategorization).valid?
      activity.coding_spend_district_valid  = CodingTree.new(activity, CodingSpendDistrict).valid?

      activity.save(false)
    end
  end
end

puts "Deleted ** #{total_deleted} ** duplicate code_assignments in total"
