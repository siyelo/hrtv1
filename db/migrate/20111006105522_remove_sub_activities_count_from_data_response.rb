class RemoveSubActivitiesCountFromDataResponse < ActiveRecord::Migration
  def self.up
    remove_column :data_responses, :sub_activities_count
  end

  def self.down
    add_column :data_responses, :sub_activities_count, :integer, :default => 0
  end
end
