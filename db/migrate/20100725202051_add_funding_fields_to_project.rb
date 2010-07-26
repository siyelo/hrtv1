class AddFundingFieldsToProject < ActiveRecord::Migration
  def self.up
    remove_column :projects, :expected_total
    add_column :projects, :budget, :decimal
    add_column :projects, :spend, :decimal
    add_column :projects, :entire_budget, :decimal
   end

  def self.down
    remove_column :projects, :entire_budget
    remove_column :projects, :spend
    remove_column :projects, :budget
    add_column :projects, :expected_total, :decimal
  end
end
