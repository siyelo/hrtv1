class FixInvalidSubImplementers < ActiveRecord::Migration
  def self.up
    load 'db/fixes/fix_invalid_sub_implementers.rb'
  end

  def self.down
    puts "irreversible"
  end
end
