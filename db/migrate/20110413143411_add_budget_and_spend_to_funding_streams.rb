class AddBudgetAndSpendToFundingStreams < ActiveRecord::Migration
  def self.up
    add_column :funding_streams, :budget, :decimal, :default => 0
    add_column :funding_streams, :spend, :decimal, :default => 0
  end

  def self.down
    remove_column :funding_streams, :spend
    remove_column :funding_streams, :budget
  end
end
