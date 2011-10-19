class ActivityRemoveStartEndDate < ActiveRecord::Migration
  def self.up
    remove_column :activities, :start_date
    remove_column :activities, :end_date
  end

  def self.down
    add_column :activities, :start_date, :datetime
    add_column :activities, :end_date, :datetime
  end
end
