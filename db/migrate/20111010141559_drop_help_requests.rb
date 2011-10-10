class DropHelpRequests < ActiveRecord::Migration
  def self.up
    drop_table "help_requests"
  end

  def self.down
    create_table "help_requests", :force => true do |t|
      t.string   "email"
      t.text     "message"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
