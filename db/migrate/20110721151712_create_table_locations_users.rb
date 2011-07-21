class CreateTableLocationsUsers < ActiveRecord::Migration
  def self.up
    create_table :locations_users, :id => false do |t|
      t.integer :location_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :locations_users
  end
end
