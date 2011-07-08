class RemoveStartDateAndEndDateFromDataRequest < ActiveRecord::Migration
  def self.up
    remove_column :data_requests, :start_date
    remove_column :data_requests, :end_date
  end

  def self.down
    add_column :data_requests, :start_date, :date
    add_column :data_requests, :end_date, :date
  end
end
