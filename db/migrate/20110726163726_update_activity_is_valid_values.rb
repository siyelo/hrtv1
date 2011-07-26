class UpdateActivityIsValidValues < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110726_update_activity_valid_values.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
