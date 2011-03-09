class AddProjectIdToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :project_id, :integer
  end

  def self.down
    remove_column :activities, :project_id
  end
end
