class RemoveStartAndEndDatesFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :start_date
    remove_column :projects, :end_date
  end

  def self.down
    add_column :projects, :start_date, :date
    add_column :projects, :end_date, :date
  end
end
