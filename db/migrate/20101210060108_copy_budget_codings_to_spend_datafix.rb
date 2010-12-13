class CopyBudgetCodingsToSpendDatafix < ActiveRecord::Migration
  def self.up
    Activity.all.each do |a|
      if a.use_budget_codings_for_spend
        puts "Activity #{a.id} has 'use budget codings' checked."
        puts "  copying codings to spend..."
        a.copy_budget_codings_to_spend
        puts "  codings copied."
      end
    end
  end

  def self.down
  end
end
