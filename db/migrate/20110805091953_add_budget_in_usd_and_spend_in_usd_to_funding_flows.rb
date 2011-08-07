class AddBudgetInUsdAndSpendInUsdToFundingFlows < ActiveRecord::Migration
  def self.up
    add_column :funding_flows, :budget_in_usd, :decimal, :default => 0.0
    add_column :funding_flows, :spend_in_usd, :decimal, :default => 0.0
  end

  def self.down
    remove_column :funding_flows, :spend_in_usd
    remove_column :funding_flows, :budget_in_usd
  end
end
