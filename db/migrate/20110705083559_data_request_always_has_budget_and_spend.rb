class DataRequestAlwaysHasBudgetAndSpend < ActiveRecord::Migration
  def self.up
    remove_column :data_requests, :budget
    remove_column :data_requests, :spend
  end

  def self.down
    add_column :data_requests, :budget, :boolean, :default => true
    add_column :data_requests, :spend, :boolean, :default => true
  end
end
