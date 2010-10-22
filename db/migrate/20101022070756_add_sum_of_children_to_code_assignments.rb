class AddSumOfChildrenToCodeAssignments < ActiveRecord::Migration
  def self.up
    add_column :code_assignments, :sum_of_children, :decimal
  end

  def self.down
    remove_column :code_assignments, :sum_of_children
  end
end
