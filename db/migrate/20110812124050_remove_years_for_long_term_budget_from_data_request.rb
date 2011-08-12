class RemoveYearsForLongTermBudgetFromDataRequest < ActiveRecord::Migration
  def self.up
    remove_column :data_requests, :year_2
    remove_column :data_requests, :year_3
    remove_column :data_requests, :year_4
    remove_column :data_requests, :year_5
  end

  def self.down
    add_column :data_requests, :year_2, :default => true
    add_column :data_requests, :year_3, :default => true
    add_column :data_requests, :year_4, :default => true
    add_column :data_requests, :year_5, :default => true
  end
end
