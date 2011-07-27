class RemoveAllNonFutureBudgetsFields < ActiveRecord::Migration
  def self.up
    remove_column :activities, :budget_q1
    remove_column :activities, :budget_q2
    remove_column :activities, :budget_q3
    remove_column :activities, :budget_q4
    remove_column :activities, :budget_q4_prev
    remove_column :projects, :budget
  end

  def self.down
    add_column :activities, :budget_q1, :decimal
    add_column :activities, :budget_q2, :decimal
    add_column :activities, :budget_q3, :decimal
    add_column :activities, :budget_q4, :decimal
    add_column :activities, :budget_q4_prev, :decimal
    add_column :projects, :budget, :decimal
  end
end
