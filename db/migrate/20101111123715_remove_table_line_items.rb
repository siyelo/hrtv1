class RemoveTableLineItems < ActiveRecord::Migration
  def self.up
    drop_table :line_items
  end

  def self.down
    create_table "line_items", :force => true do |t|
      t.text      "description"
      t.integer   "activity_id"
      t.timestamp "created_at"
      t.timestamp "updated_at"
      t.integer   "activity_cost_category_id"
      t.decimal   "budget"
      t.decimal   "spend"
    end
  end
end
