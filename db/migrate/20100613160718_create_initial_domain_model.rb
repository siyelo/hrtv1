class CreateInitialDomainModel < ActiveRecord::Migration
  def self.up
    create_table "activities", :force => true do |t|
      t.string   "name"
      t.string   "description"
      t.string   "beneficiary"
      t.string   "target"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "comments"
      t.decimal  "expected_total"
      t.text     "newfield"
    end

    create_table "activities_indicators", :id => false, :force => true do |t|
      t.integer "activity_id"
      t.integer "indicator_id"
    end

    create_table "codes", :force => true do |t|
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.string   "short_display"
      t.string   "long_display"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.date     "start_date"
      t.date     "end_date"
      t.integer  "replacement_code_id"
    end

    create_table "indicators", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.string   "source"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "line_items", :force => true do |t|
      t.text     "description"
      t.integer  "activity_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "amount"
      t.integer  "hssp_strategic_objective_id"
      t.integer  "mtefp_id"
    end

    create_table "locations", :force => true do |t|
      t.string   "name"
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "sessions", :force => true do |t|
      t.string   "session_id", :null => false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    
  end

  def self.down
    

    remove_index "sessions", :name => "index_sessions_on_updated_at"
    remove_index "sessions", :name => "index_sessions_on_session_id"

    drop_table "sessions"

    drop_table "locations"

    drop_table "line_items"

    drop_table "indicators"

    drop_table "codes"

    drop_table "activities_indicators"

    drop_table "activities"
  end
end
