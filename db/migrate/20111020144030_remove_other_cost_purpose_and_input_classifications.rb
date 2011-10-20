class RemoveOtherCostPurposeAndInputClassifications < ActiveRecord::Migration
  def self.up
    other_costs = OtherCost.all.map(&:id)
    if other_costs.present?
      CodingBudget.destroy_all(['activity_id IN (?)', other_costs])
      CodingSpend.destroy_all(['activity_id IN (?)', other_costs])
      CodingBudgetCostCategorization.destroy_all(['activity_id IN (?)', other_costs])
      CodingSpendCostCategorization.destroy_all(['activity_id IN (?)', other_costs])
    end
  end

  def self.down
    puts 'irreversible migration'
  end
end
