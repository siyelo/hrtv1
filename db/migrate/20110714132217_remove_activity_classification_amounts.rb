class RemoveActivityClassificationAmounts < ActiveRecord::Migration
  def self.up
    remove_column :activities, :CodingBudget_amount
    remove_column :activities, :CodingBudgetCostCategorization_amount
    remove_column :activities, :CodingBudgetDistrict_amount
    remove_column :activities, :CodingSpend_amount
    remove_column :activities, :CodingSpendCostCategorization_amount
    remove_column :activities, :CodingSpendDistrict_amount
  end

  def self.down
    add_column :activities, :CodingBudget_amount,:default => 0
    add_column :activities, :CodingBudgetCostCategorization_amount,:default => 0
    add_column :activities, :CodingBudgetDistrict_amount,:default => 0
    add_column :activities, :CodingSpend_amount,:default => 0
    add_column :activities, :CodingSpendCostCategorization_amount,:default => 0
    add_column :activities, :CodingSpendDistrict_amount,:default => 0
  end
end
