class CopyBudgetCodingsToSpendDatafix < ActiveRecord::Migration
  def self.up
    Activity.all.each do |a|
      if a.use_budget_codings_for_spend
        a.copy_budget_codings_to_spend
      end
    end
  end

  def self.down
  end
end
