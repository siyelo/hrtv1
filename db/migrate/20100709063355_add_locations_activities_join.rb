class AddLocationsActivitiesJoin < ActiveRecord::Migration
  def self.up
    create_table :activities_locations, :id=>false do |t|
      t.references :activity
      t.references :location
    end
  end

  def self.down
    drop_table :activities_locations
  end
end
