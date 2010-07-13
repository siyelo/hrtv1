class AddOtherCostFieldsToActivityTable < ActiveRecord::Migration
  def self.up
    add_column :activities, :other_cost_type_id, :integer
  end

  def self.down
    remove_column :activities, :other_cost_type_id
  end
end
