class AddBudgetInUsdAndSpendInUsdToFundingStreams < ActiveRecord::Migration
  def self.up
    add_column :funding_streams, :budget_in_usd, :decimal, :default => 0.0
    add_column :funding_streams, :spend_in_usd, :decimal, :default => 0.0
  end

  def self.down
    remove_column :funding_streams, :spend_in_usd
    remove_column :funding_streams, :budget_in_usd
  end
end
