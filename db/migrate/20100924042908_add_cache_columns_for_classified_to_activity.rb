class AddCacheColumnsForClassifiedToActivity < ActiveRecord::Migration
  load File.join(Rails.root, 'app', 'models', 'activity.rb') # load activity model

  def self.up
    add_column :activities, "#{CodingBudget}_amount", :decimal, :default => 0
    add_column :activities, "#{CodingBudgetCostCategorization}_amount", :decimal, :default => 0
    add_column :activities, "#{CodingBudgetDistrict}_amount", :decimal, :default => 0
    add_column :activities, "#{CodingSpend}_amount", :decimal, :default => 0
    add_column :activities, "#{CodingSpendCostCategorization}_amount", :decimal, :default => 0
    add_column :activities, "#{CodingSpendDistrict}_amount", :decimal, :default => 0
  end

  def self.down
    remove_column :activities, "#{CodingBudget}_amount"
    remove_column :activities, "#{CodingBudgetCostCategorization}_amount"
    remove_column :activities, "#{CodingBudgetDistrict}_amount"
    remove_column :activities, "#{CodingSpend}_amount"
    remove_column :activities, "#{CodingSpendCostCategorization}_amount"
    remove_column :activities, "#{CodingSpendDistrict}_amount"
  end
end
