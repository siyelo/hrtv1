class AddDefaultZeroToSumOfChildrenInCodeAssignmentsTable < ActiveRecord::Migration
  def self.up
    change_column :code_assignments, :sum_of_children, :decimal, :default => 0
  end

  def self.down
    change_column :code_assignments, :sum_of_children, :decimal
  end
end
