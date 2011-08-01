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
