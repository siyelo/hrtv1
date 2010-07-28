class AddPercentageToCodeAssignment < ActiveRecord::Migration
  def self.up
    add_column :code_assignments, :percentage, :decimal
  end

  def self.down
    remove_column :code_assignments, :percentage
  end
end
