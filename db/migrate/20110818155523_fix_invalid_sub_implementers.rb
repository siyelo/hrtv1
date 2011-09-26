class FixInvalidSubImplementers < ActiveRecord::Migration
  def self.up
  	p "deprecated"
  end

  def self.down
    puts "irreversible"
  end
end
