class AddCachedAmountToCodeAssignment < ActiveRecord::Migration
  def self.up
    add_column :code_assignments, :cached_amount, :decimal
  end

  def self.down
    remove_column :code_assignments, :cached_amount
  end
end
