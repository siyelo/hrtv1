class AddAmountToCodeAssignments < ActiveRecord::Migration

  def self.up
    add_column :code_assignments, :amount, :decimal
  end

  def self.down
    remove_column :code_assignments, :amount
  end
end
