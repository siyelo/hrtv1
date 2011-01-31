class FixCodeTypes < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110131_fix_code_types.rb'
  end

  def self.down
  end
end
