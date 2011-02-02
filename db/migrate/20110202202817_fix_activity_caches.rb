class FixActivityCaches < ActiveRecord::Migration
  def self.up
    load 'db/fixes/update_activity_cached_amount_columns.rb'
  end

  def self.down
  end
end
