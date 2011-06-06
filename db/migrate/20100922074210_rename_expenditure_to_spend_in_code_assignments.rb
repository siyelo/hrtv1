# Define removed model CodingExpenditure
class CodingExpenditure < CodeAssignment
end

# Define removed model CodingExpenditureCostCategorization
class CodingExpenditureCostCategorization < CodeAssignment
end

# Define removed model CodingExpenditureDistrict
class CodingExpenditureDistrict < CodeAssignment
end

class RenameExpenditureToSpendInCodeAssignments < ActiveRecord::Migration
  def self.up
    CodeAssignment.with_type("CodingExpenditure").each do |ca|
      ca.type = "CodingSpend"
      ca.save(false)
    end

    CodeAssignment.with_type("CodingExpenditureCostCategorization").each do |ca|
      ca.type = "CodingSpendCostCategorization"
      ca.save(false)
    end
 
    CodeAssignment.with_type("CodingExpenditureDistrict").each do |ca|
      ca.type = "CodingSpendDistrict"
      ca.save(false)
    end
 end

  def self.down
  end
end
