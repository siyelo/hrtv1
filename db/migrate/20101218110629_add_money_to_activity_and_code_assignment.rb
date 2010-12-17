class AddMoneyToActivityAndCodeAssignment < ActiveRecord::Migration
  def self.up
    add_column :activities, :new_spend, :integer, :null => false, :default => 0
    add_column :activities, :new_spend_currency, :string
    add_column :activities, :new_budget, :integer, :null => false, :default => 0
    add_column :activities, :new_budget_currency, :string
    add_column :code_assignments, :new_amount, :integer, :null => false, :default => 0
    add_column :code_assignments, :new_amount_currency, :string
  end

  def self.down
    remove_column :activities, :new_spend_currency
    remove_column :activities, :new_spend
    remove_column :activities, :new_budget_currency
    remove_column :activities, :new_budget
    remove_column :code_assignments, :new_amount
    remove_column :code_assignments, :new_amount_currency
  end
end
