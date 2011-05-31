class AddUnclassifiedActivitiesCountToDataResponses < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :unclassified_activities_count, :integer, :default => 0

    DataResponse.reset_column_information
    DataResponse.find(:all).each do |dr|
      DataResponse.update_counters(dr.id,
        :unclassified_activities_count => dr.activities.only_simple.unclassified.length)
    end
  end

  def self.down
    remove_column :data_responses, :unclassified_activities_count
  end
end
