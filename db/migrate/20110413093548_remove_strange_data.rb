class RemoveStrangeData < ActiveRecord::Migration
  def self.up
    p = Project.find_by_id(278)
    p.delete if p
  end

  def self.down
    puts "irreversible migration - data fix"
  end
end
