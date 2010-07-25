class AlterActivitiesMakeStrtEndDates < ActiveRecord::Migration
  def self.up
    remove_column :activities, :start_month
    remove_column :activities, :end_month
    add_column :activities, :start, :date
    add_column :activities, :end, :date
  end

  def self.down
    remove_column :activities, :end
    remove_column :activities, :start
    add_column :activities, :end_month, :string
    add_column :activities, :start_month, :string
  end
end
