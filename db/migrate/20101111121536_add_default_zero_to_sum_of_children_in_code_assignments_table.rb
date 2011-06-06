class AddDefaultZeroToSumOfChildrenInCodeAssignmentsTable < ActiveRecord::Migration
  def self.up
    change_column :code_assignments, :sum_of_children, :decimal, :default => 0
    CodeAssignment.reset_column_information
    CodeAssignment.update_all "sum_of_children = 0", ["sum_of_children is NULL"]
  end

  def self.down
    change_column :code_assignments, :sum_of_children, :decimal
  end
end
