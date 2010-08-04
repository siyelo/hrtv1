# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100804182517) do

  create_table "abilities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.string   "beneficiary"
    t.string   "target"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "provider_id"
    t.integer  "other_cost_type_id"
    t.text     "description"
    t.string   "type"
    t.decimal  "budget"
    t.decimal  "spend_q1"
    t.decimal  "spend_q2"
    t.decimal  "spend_q3"
    t.decimal  "spend_q4"
    t.date     "start"
    t.date     "end"
    t.decimal  "spend"
    t.text     "text_for_provider"
    t.text     "text_for_targets"
    t.text     "text_for_beneficiaries"
    t.integer  "organization_id_owner"
    t.decimal  "spend_q4_prev"
  end

  create_table "activities_beneficiaries", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "beneficiary_id"
  end

  create_table "activities_indicators", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "indicator_id"
  end

  create_table "activities_locations", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "location_id"
  end

  create_table "activities_organizations", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "organization_id"
  end

  create_table "activities_projects", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "activity_id"
  end

  create_table "assignments", :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "code_assignments", :force => true do |t|
    t.integer "activity_id"
    t.integer "code_id"
    t.string  "code_type"
    t.decimal "amount"
    t.string  "type"
    t.decimal "percentage"
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
    t.string   "type"
    t.string   "external_id"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment",                        :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "data_elements", :force => true do |t|
    t.integer "data_response_id"
    t.integer "data_elementable_id"
    t.string  "data_elementable_type"
  end

  add_index "data_elements", ["data_elementable_id"], :name => "index_data_elements_on_data_elementable_id"
  add_index "data_elements", ["data_elementable_type"], :name => "index_data_elements_on_data_elementable_type"
  add_index "data_elements", ["data_response_id"], :name => "index_data_elements_on_data_response_id"

  create_table "data_requests", :force => true do |t|
    t.integer  "organization_id_requester"
    t.string   "title"
    t.boolean  "complete",                  :default => false
    t.boolean  "pending_review",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_responses", :force => true do |t|
    t.integer  "data_element_id"
    t.integer  "data_request_id"
    t.boolean  "complete",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id_responder"
    t.string   "currency"
    t.date     "fiscal_year_start_date"
    t.date     "fiscal_year_end_date"
  end

  add_index "data_responses", ["data_request_id"], :name => "index_data_responses_on_data_request_id"

  create_table "field_helps", :force => true do |t|
    t.string   "attribute_name"
    t.string   "short"
    t.text     "long"
    t.integer  "model_help_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funding_flows", :force => true do |t|
    t.integer  "organization_id_from"
    t.integer  "organization_id_to"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "budget"
    t.decimal  "spend_q1"
    t.decimal  "spend_q2"
    t.decimal  "spend_q3"
    t.decimal  "spend_q4"
    t.integer  "organization_id_owner"
    t.text     "organization_text"
    t.integer  "self_provider_flag",    :default => 0
    t.decimal  "spend"
    t.decimal  "spend_q4_prev"
  end

  create_table "help_requests", :force => true do |t|
    t.string   "email"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "activity_cost_category_id"
    t.decimal  "budget"
    t.decimal  "spend"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations_organizations", :id => false, :force => true do |t|
    t.integer "location_id"
    t.integer "organization_id"
  end

  create_table "locations_projects", :id => false, :force => true do |t|
    t.integer "location_id"
    t.integer "project_id"
  end

  create_table "model_helps", :force => true do |t|
    t.string   "model_name"
    t.string   "short"
    t.text     "long"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "raw_type"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "budget"
    t.decimal  "spend"
    t.decimal  "entire_budget"
    t.integer  "organization_id_owner"
    t.string   "currency"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "roles_mask"
    t.integer  "organization_id"
    t.integer  "data_response_id_current"
    t.text     "text_for_organization"
  end

end
