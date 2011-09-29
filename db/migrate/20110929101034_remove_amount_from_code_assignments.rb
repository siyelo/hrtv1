class RemoveAmountFromCodeAssignments < ActiveRecord::Migration
  def self.up
    remove_column :code_assignments, :amount
  end

  def self.down
    add_column :code_assignments, :amount, :decimal
  end
end
