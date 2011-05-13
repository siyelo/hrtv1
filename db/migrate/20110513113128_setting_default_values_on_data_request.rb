class SettingDefaultValuesOnDataRequest < ActiveRecord::Migration
  def self.up
    load 'db/fixes/add_default_values_to_datarequests.rb'
  end

  def self.down
  end
end
