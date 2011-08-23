class RemoveProjectAmounts < ActiveRecord::Migration
  def self.up
    remove_column :projects, :budget
    remove_column :projects, :budget_q4_prev
    remove_column :projects, :budget_q1
    remove_column :projects, :budget_q2
    remove_column :projects, :budget_q3
    remove_column :projects, :budget_q4
    remove_column :projects, :spend
    remove_column :projects, :spend_q4_prev
    remove_column :projects, :spend_q1
    remove_column :projects, :spend_q2
    remove_column :projects, :spend_q3
    remove_column :projects, :spend_q4
  end

  def self.down
    add_column :projects, :budget, :decimal
    add_column :projects, :budget_q4_prev, :decimal
    add_column :projects, :budget_q1, :decimal
    add_column :projects, :budget_q2, :decimal
    add_column :projects, :budget_q3, :decimal
    add_column :projects, :budget_q4, :decimal
    add_column :projects, :spend, :decimal
    add_column :projects, :spend_q4_prev, :decimal
    add_column :projects, :spend_q1, :decimal
    add_column :projects, :spend_q2, :decimal
    add_column :projects, :spend_q3, :decimal
    add_column :projects, :spend_q4, :decimal
  end
end
