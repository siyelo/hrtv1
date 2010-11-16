class AddCounterCaches < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :projects_count, :integer, :default => 0
    add_column :data_responses, :comments_count, :integer, :default => 0
    add_column :data_responses, :activities_count, :integer, :default => 0
    add_column :data_responses, :sub_activities_count, :integer, :default => 0
    add_column :data_responses, :activities_without_projects_count, :integer, :default => 0
    add_column :projects, :comments_count, :integer, :default => 0
    add_column :activities, :comments_count, :integer, :default => 0
    add_column :activities, :sub_activities_count, :integer, :default => 0

    DataResponse.reset_column_information
    DataResponse.find(:all).each do |dr|
      DataResponse.update_counters(dr.id, :projects_count => dr.projects.length)
      DataResponse.update_counters(dr.id, :comments_count => dr.comments.length)
      DataResponse.update_counters(dr.id, :activities_count => dr.activities.only_simple.length)
      DataResponse.update_counters(dr.id, :sub_activities_count => dr.sub_activities.length)
      DataResponse.update_counters(dr.id, :activities_without_projects_count => dr.activities.roots.without_a_project.length)
    end

    Project.reset_column_information
    Project.find(:all).each do |p|
      Project.update_counters(p.id, :comments_count => p.comments.length)
    end

    Activity.reset_column_information
    Activity.find(:all).each do |a|
      Activity.update_counters(a.id, :comments_count => a.comments.length)
      Activity.update_counters(a.id, :sub_activities_count => a.sub_activities.length)
    end
  end

  def self.down
    remove_column :data_responses, :projects_count
    remove_column :data_responses, :comments_count
    remove_column :data_responses, :activities_count
    remove_column :data_responses, :sub_activities_count
    remove_column :data_responses, :activities_without_projects_count
    remove_column :projects, :comments_count
    remove_column :activities, :comments_count
    remove_column :activities, :sub_activities_count
  end
end
