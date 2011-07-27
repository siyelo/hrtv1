class RemoveServiceLevelAmounts < ActiveRecord::Migration
  def self.up
    remove_column :activities, "ServiceLevelBudget_amount"
    remove_column :activities, "ServiceLevelSpend_amount"
  end

  def self.down
    add_column :activities, "ServiceLevelSpend_amount", :default => 0
    add_column :activities, "ServiceLevelBudget_amount", :default => 0
  end
end
