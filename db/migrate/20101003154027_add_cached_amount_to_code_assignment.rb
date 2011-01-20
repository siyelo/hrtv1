class AddCachedAmountToCodeAssignment < ActiveRecord::Migration
  def self.up
    add_column :code_assignments, :cached_amount, :decimal
    Activity.all.each do |a|
      if [OtherCost, Activity].include?(a.class)
        [CodingBudget,CodingBudgetCostCategorization,CodingBudgetDistrict,CodingSpend,CodingSpendCostCategorization,CodingSpendDistrict].each do |type|
          a.update_classified_amount_cache(type)
        end
      end
    end
  end

  def self.down
    remove_column :code_assignments, :cached_amount
  end
end
