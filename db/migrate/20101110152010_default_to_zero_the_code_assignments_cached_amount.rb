class DefaultToZeroTheCodeAssignmentsCachedAmount < ActiveRecord::Migration
  def self.up
    change_column :code_assignments, :cached_amount, :decimal, :default => 0
    CodeAssignment.reset_column_information
    CodeAssignment.update_all "cached_amount = 0", ["cached_amount is NULL"]
  end

  def self.down
    change_column :code_assignments, :cached_amount, :decimal
  end
end
