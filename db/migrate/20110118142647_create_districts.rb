class CreateDistricts < ActiveRecord::Migration
  def self.up
    create_table :districts do |t|
      t.string :name
      t.integer :population
      t.integer :old_location_id

      t.timestamps
    end
  end

  def self.down
    drop_table :districts
  end
end
