class AddQuarterlyBudgetsCheckToDataResponse < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :budget_by_quarter, :boolean, :default => false
  end

  def self.down
    remove_column :data_requests, :budget_by_quarter
  end
end