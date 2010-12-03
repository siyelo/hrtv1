class RemoveLocationsTable < ActiveRecord::Migration
  def self.up
    drop_table :locations
  end

  def self.down
    create_table "locations", :force => true do |t|
      t.string   "name"
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
