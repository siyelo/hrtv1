class FixActivitiesWithoutProject < ActiveRecord::Migration
  def self.up
    load 'db/fixes/assign_activities_without_a_project.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
