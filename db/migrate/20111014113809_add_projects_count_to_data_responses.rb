class AddProjectsCountToDataResponses < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :projects_count, :integer, :default => 0

    DataResponse.find(:all).each do |dr|
      DataResponse.update_counters(dr.id, :projects_count => dr.projects.length)
    end
  end

  def self.down
    remove_column :data_responses, :projects_count
  end
end
