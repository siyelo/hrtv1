# redefine removed classes to prevent AR from crying
class ServiceLevelBudget < CodeAssignment; end
class ServiceLevelSpend < CodeAssignment; end
class ServiceLevel < Code; end
class AddIsClassifiedFieldsToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :coding_budget_valid, :boolean, :default => false
    add_column :activities, :coding_budget_cc_valid, :boolean, :default => false
    add_column :activities, :coding_budget_district_valid, :boolean, :default => false
    add_column :activities, :service_level_budget_valid, :boolean, :default => false
    add_column :activities, :coding_spend_valid, :boolean, :default => false
    add_column :activities, :coding_spend_cc_valid, :boolean, :default => false
    add_column :activities, :service_level_spend_valid, :boolean, :default => false
    add_column :activities, :coding_spend_district_valid, :boolean, :default => false

    Activity.reset_column_information

    activities     = Activity.all
    activity_total = activities.length

    activities.each_with_index do |activity, index|
      puts "Updating classifications for activity: #{activity.id} | #{index + 1}/#{activity_total}: "
      activity.coding_budget_valid          = CodingTree.new(activity, CodingBudget).valid?
      activity.coding_budget_cc_valid       = CodingTree.new(activity, CodingBudgetCostCategorization).valid?
      activity.coding_budget_district_valid = CodingTree.new(activity, CodingBudgetDistrict).valid?

      activity.coding_spend_valid           = CodingTree.new(activity, CodingSpend).valid?
      activity.coding_spend_cc_valid        = CodingTree.new(activity, CodingSpendCostCategorization).valid?
      activity.coding_spend_district_valid  = CodingTree.new(activity, CodingSpendDistrict).valid?
      activity.save(false)
    end
  end

  def self.down
    remove_column :activities, :coding_budget_valid
    remove_column :activities, :coding_budget_cc_valid
    remove_column :activities, :coding_budget_district_valid
    remove_column :activities, :service_level_budget_valid
    remove_column :activities, :coding_spend_valid
    remove_column :activities, :coding_spend_cc_valid
    remove_column :activities, :service_level_spend_valid
    remove_column :activities, :coding_spend_district_valid
  end
end
