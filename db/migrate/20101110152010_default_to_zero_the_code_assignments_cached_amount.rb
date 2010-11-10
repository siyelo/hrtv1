class DefaultToZeroTheCodeAssignmentsCachedAmount < ActiveRecord::Migration
  def self.up
    change_column :code_assignments, :cached_amount, :decimal, :default => 0
  end

  def self.down
    change_column :code_assignments, :cached_amount, :decimal
  end
end
