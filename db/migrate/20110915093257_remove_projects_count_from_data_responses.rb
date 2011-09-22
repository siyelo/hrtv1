class RemoveProjectsCountFromDataResponses < ActiveRecord::Migration
  def self.up
    remove_column :data_responses, :projects_count
  end

  def self.down
    add_column :data_responses, :projects_count, :integer
  end
end
