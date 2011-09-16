class RemoveActivitiesWithoutProject < ActiveRecord::Migration
  def self.up
    load "db/fixes/20110916_remove_activities_without_project.rb"
  end

  def self.down
    puts 'irreversible migration'
  end
end
