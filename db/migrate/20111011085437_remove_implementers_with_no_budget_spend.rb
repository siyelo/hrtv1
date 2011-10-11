class RemoveImplementersWithNoBudgetSpend < ActiveRecord::Migration
  def self.up
    if Rails.env != "test"
      load 'db/fixes/20111011_remove_sole_implementer_splits_with_0_budgetspend.rb'
    end
  end

  def self.down
    p "IRREVERSIBLE MIGRATION"
  end
end
