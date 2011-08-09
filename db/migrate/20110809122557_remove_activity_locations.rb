class RemoveActivityLocations < ActiveRecord::Migration
  def self.up
    drop_table :activities_locations
  end

  def self.down
    create_table :activities_locations, :id => false do |t|
      t.integer :activity_id
      t.integer :location_id
    end
  end
end
