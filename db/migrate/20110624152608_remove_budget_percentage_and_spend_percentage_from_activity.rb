class RemoveBudgetPercentageAndSpendPercentageFromActivity < ActiveRecord::Migration
  def self.up
    remove_column :activities, :budget_percentage
    remove_column :activities, :spend_percentage
  end

  def self.down
    add_column :activities, :spend_percentage, :decimal
    add_column :activities, :budget_percentage, :decimal
  end
end
