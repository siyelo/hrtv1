class AddUnclassifiedActivitiesCountToDataResponses < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :unclassified_activities_count, :integer, :default => 0
  end

  def self.down
    remove_column :data_responses, :unclassified_activities_count
  end
end
