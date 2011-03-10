class DropActivitiesProjectsTable < ActiveRecord::Migration
  def self.up
    drop_table "activities_projects"
  end

  def self.down
    create_table "activities_projects", :id => false, :force => true do |t|
      t.integer "project_id"
      t.integer "activity_id"
    end
  end
end
