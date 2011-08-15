class MoveImplementersToSubActivities < ActiveRecord::Migration
  def self.up
    load 'db/fixes/move_implementers_to_sub_activities.rb'
  end

  def self.down
    puts "irreversible"
  end
end
