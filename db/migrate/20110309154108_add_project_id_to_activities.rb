class AddProjectIdToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :project_id, :integer
    Activity.reset_column_information
  end

  def self.down
    remove_column :activities, :project_id
  end
end
