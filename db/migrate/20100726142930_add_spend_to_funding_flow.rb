class AddSpendToFundingFlow < ActiveRecord::Migration
  def self.up
    add_column :funding_flows, :spend, :decimal
  end

  def self.down
    remove_column :funding_flows, :spend
  end
end
