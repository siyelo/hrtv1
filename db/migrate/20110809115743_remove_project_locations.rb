class RemoveProjectLocations < ActiveRecord::Migration
  def self.up
    drop_table :locations_projects
  end

  def self.down
    create_table :locations_projects, :id => false do |t|
      t.integer :location_id
      t.integer :project_id
    end
  end
end
