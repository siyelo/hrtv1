class RemoveFundingStreamsTable < ActiveRecord::Migration
  def self.up
    drop_table :funding_streams
  end

  def self.down
    create_table "funding_streams", :force => true do |t|
      t.integer  "project_id"
      t.integer  "organization_ufs_id"
      t.integer  "organization_fa_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "budget",              :default => 0.0
      t.decimal  "spend",               :default => 0.0
      t.decimal  "budget_in_usd",       :default => 0.0
      t.decimal  "spend_in_usd",        :default => 0.0
    end
  end
end
