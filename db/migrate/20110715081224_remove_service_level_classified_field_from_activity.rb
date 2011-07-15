class RemoveServiceLevelClassifiedFieldFromActivity < ActiveRecord::Migration
  def self.up
    remove_column :activities, :service_level_budget_valid
    remove_column :activities, :service_level_spend_valid
  end

  def self.down
    add_column :activities, :service_level_budget_valid, :boolean, :default => false
    add_column :activities, :service_level_spend_valid, :boolean, :default => false
  end
end
