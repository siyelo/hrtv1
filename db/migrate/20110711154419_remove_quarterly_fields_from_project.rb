class RemoveQuarterlyFieldsFromProject < ActiveRecord::Migration
  def self.up
    remove_column :projects, :spend_q1
    remove_column :projects, :spend_q2
    remove_column :projects, :spend_q3
    remove_column :projects, :spend_q4
    remove_column :projects, :spend_q4_prev
    remove_column :projects, :budget_q1
    remove_column :projects, :budget_q2
    remove_column :projects, :budget_q3
    remove_column :projects, :budget_q4
    remove_column :projects, :budget_q4_prev
  end

  def self.down
    add_column :projects, :spend_q1, :integer
    add_column :projects, :spend_q2, :integer
    add_column :projects, :spend_q3, :integer
    add_column :projects, :spend_q4, :integer
    add_column :projects, :spend_q4_prev, :integer
    add_column :projects, :budget_q1, :integer
    add_column :projects, :budget_q2, :integer
    add_column :projects, :budget_q3, :integer
    add_column :projects, :budget_q4, :integer
    add_column :projects, :budget_q4_prev, :integer
  end
end
