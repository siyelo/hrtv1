class InflowDataFix < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20111104_dynamic_query_inflow_datafix.rb' unless Rails.env == "test"
  end

  def self.down
    p "IRREVERSIBLE MIGRATION"
  end
end
