# redefine removed classes to prevent AR from crying
class ServiceLevelBudget < CodeAssignment; end
class ServiceLevelSpend < CodeAssignment; end
class ServiceLevel < Code; end

class RemoveServiceLevelCodeAssignments < ActiveRecord::Migration
  def self.up
    CodeAssignment.delete_all("type = 'ServiceLevelBudget'")
    CodeAssignment.delete_all("type = 'ServiceLevelSpend'")
    Code.delete_all("type = 'ServiceLevel'")
  end

  def self.down
    puts 'irreversible migration'
  end
end
