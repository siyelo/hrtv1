class RemoveUseBudgetCodingsForSpendFromActivity < ActiveRecord::Migration
  def self.up
    remove_column :activities, :use_budget_codings_for_spend
  end

  def self.down
    add_column :activities, :use_budget_codings_for_spend, :boolean, :default => false
  end
end
