class RemoveStartAndEndDatesFromActivities < ActiveRecord::Migration
  def self.up
    remove_column :activities, :start_date
    remove_column :activities, :end_date
  end

  def self.down
    add_column :activities, :start_date, :date
    add_column :activities, :end_date, :date
  end
end
