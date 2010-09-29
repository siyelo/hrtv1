class AddUseBudgetCodingsForSpendToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :use_budget_codings_for_spend, :boolean, :default => false
  end

  def self.down
    remove_column :activities, :use_budget_codings_for_spend
  end
end
