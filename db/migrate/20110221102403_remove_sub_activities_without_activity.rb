class RemoveSubActivitiesWithoutActivity < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110221_remove_sub_activities_without_activity.rb'
  end

  def self.down
  end
end
