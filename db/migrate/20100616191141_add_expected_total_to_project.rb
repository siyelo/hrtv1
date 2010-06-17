class AddExpectedTotalToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :expected_total, :decimal
  end

  def self.down
    remove_column :projects, :expected_total
  end
end
