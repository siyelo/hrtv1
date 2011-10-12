class RemoveCounterCaches < ActiveRecord::Migration
  def self.up
    remove_column :data_responses, :comments_count
    remove_column :data_responses, :activities_count
    #remove_column :data_responses, :sub_activities_count
    remove_column :data_responses, :unclassified_activities_count
    remove_column :data_responses, :activities_without_projects_count
    remove_column :projects, :comments_count
    remove_column :activities, :comments_count
  end

  def self.down
    add_column :data_responses, :comments_count, :integer, :default => 0
    add_column :data_responses, :activities_count, :integer, :default => 0
    add_column :data_responses, :unclassified_activities_count, :integer, :default => 0
    add_column :data_responses, :activities_without_projects_count, :integer, :default => 0
    add_column :projects, :comments_count, :integer, :default => 0
    add_column :activities, :comments_count, :integer, :default => 0
  end
end
