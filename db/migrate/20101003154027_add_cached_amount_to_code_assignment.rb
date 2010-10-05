class AddCachedAmountToCodeAssignment < ActiveRecord::Migration
  def self.up
    add_column :code_assignments, :cached_amount, :decimal
    #TODO loop through all activities after making sure it works
    Activity.all.each do |a|
      [CodingBudget,CodingBudgetCostCategorization,CodingBudgetDistrict,CodingSpend,CodingSpendCostCategorization,CodingSpendDistrict].each do |type|
        a.update_classified_amount_cache(type)
      end
    end
  end

  def self.down
    remove_column :code_assignments, :cached_amount
  end
end
