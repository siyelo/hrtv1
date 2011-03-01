class AddStartDateAndEndDateAndBudgetAndSpendToDataRequests < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :start_date, :date
    add_column :data_requests, :end_date, :date
    add_column :data_requests, :budget, :boolean, :default => 1
    add_column :data_requests, :spend, :boolean, :default => 1
  end

  def self.down
    remove_column :data_requests, :spend
    remove_column :data_requests, :budget
    remove_column :data_requests, :end_date
    remove_column :data_requests, :start_date
  end
end
