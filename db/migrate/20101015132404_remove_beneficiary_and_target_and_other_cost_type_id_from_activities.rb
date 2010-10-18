class RemoveBeneficiaryAndTargetAndOtherCostTypeIdFromActivities < ActiveRecord::Migration
  def self.up
    remove_column :activities, :beneficiary
    remove_column :activities, :target
    remove_column :activities, :other_cost_type_id
  end

  def self.down
    add_column :activities, :other_cost_type_id, :integer
    add_column :activities, :target, :string
    add_column :activities, :beneficiary, :string
  end
end
