class UpdateExistingCodeAssignmentsToBudgetCodings < ActiveRecord::Migration
  def self.up
    CodeAssignment.all.each do |coding|
      b = coding.clone.becomes BudgetCoding
      b.type = "BudgetCoding"
      transaction do
        coding.delete
        b.save!
      end
    end
  end

  def self.down
    BudgetCoding.all.each do |b|
      c = b.clone.becomes CodeAssignment
      transaction do
        b.delete
        c.save!
      end
    end

    # lossy!
    ExpenditureCoding.all.each do |e|
      c = e.clone.becomes CodeAssignment
      transaction do
        e.delete
        c.save!
      end
    end
  end
end
