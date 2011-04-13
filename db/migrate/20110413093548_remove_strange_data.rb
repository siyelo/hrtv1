class RemoveStrangeData < ActiveRecord::Migration
  def self.up
    Project.find(278).delete
  end

  def self.down
    puts "irreversible migration - data fix"
  end
end
