class SettingDefaultValuesOnDataRequest < ActiveRecord::Migration
  def self.up
    DataRequest.reset_column_information
    load 'db/fixes/add_default_values_to_datarequests.rb'
  end

  def self.down
  end
end
