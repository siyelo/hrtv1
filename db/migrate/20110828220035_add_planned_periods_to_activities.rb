class AddPlannedPeriodsToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :planned_for_gor_q1, :boolean
    add_column :activities, :planned_for_gor_q2, :boolean
    add_column :activities, :planned_for_gor_q3, :boolean
    add_column :activities, :planned_for_gor_q4, :boolean
  end

  def self.down
    remove_column :activities, :planned_for_gor_q4
    remove_column :activities, :planned_for_gor_q3
    remove_column :activities, :planned_for_gor_q2
    remove_column :activities, :planned_for_gor_q1
  end
end
