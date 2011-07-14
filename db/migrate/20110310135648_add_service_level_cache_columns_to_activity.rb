class ServiceLevelBudget < CodeAssignment
end

class ServiceLevelSpend < CodeAssignment
end

class AddServiceLevelCacheColumnsToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, "#{ServiceLevelBudget}_amount", :decimal, :default => 0
    add_column :activities, "#{ServiceLevelSpend}_amount", :decimal, :default => 0
    Activity.reset_column_information
  end

  def self.down
    remove_column :activities, "#{ServiceLevelBudget}_amount"
    remove_column :activities, "#{ServiceLevelSpend}_amount"
  end
end
