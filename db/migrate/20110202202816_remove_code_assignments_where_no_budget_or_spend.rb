class RemoveCodeAssignmentsWhereNoBudgetOrSpend < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110202_remove_code_assignments_where_no_budget_or_spend.rb'
  end

  def self.down
  end
end
