class RemoveCodeAssignmentsForNonexistingClassificationTypes < ActiveRecord::Migration
  def self.up
    CodeAssignment.delete_all(["type IN (?)", ["BudgetCoding", "ExpenditureCoding"]])
  end

  def self.down
  end
end
