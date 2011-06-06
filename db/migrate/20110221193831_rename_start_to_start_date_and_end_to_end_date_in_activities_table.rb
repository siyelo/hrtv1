class RenameStartToStartDateAndEndToEndDateInActivitiesTable < ActiveRecord::Migration
  def self.up
    rename_column :activities, :start, :start_date
    rename_column :activities, :end, :end_date
  end

  def self.down
    rename_column :activities, :start_date, :start
    rename_column :activities, :end_date, :end
  end
end
