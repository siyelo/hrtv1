class RemoveIndicatorsTable < ActiveRecord::Migration
  def self.up
    drop_table "indicators"
  end

  def self.down
    create_table "indicators", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.string   "source"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
