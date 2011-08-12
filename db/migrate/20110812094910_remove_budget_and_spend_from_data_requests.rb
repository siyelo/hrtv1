class RemoveBudgetAndSpendFromDataRequests < ActiveRecord::Migration
  def self.up
    remove_column :data_requests, :budget
    remove_column :data_requests, :spend
  end

  def self.down
    add_column :data_requests, :spend, :boolean
    add_column :data_requests, :budget, :boolean
  end
end
