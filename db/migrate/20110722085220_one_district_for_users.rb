class OneDistrictForUsers < ActiveRecord::Migration
  def self.up
    drop_table :locations_users
    add_column :users, :location_id, :integer
  end

  def self.down
    remove_column :users, :location_id
    create_table :locations_users, :id => false do |t|
      t.integer :location_id
      t.integer :user_id
    end
  end
end
