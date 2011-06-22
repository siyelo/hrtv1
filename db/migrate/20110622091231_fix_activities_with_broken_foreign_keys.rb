class FixActivitiesWithBrokenForeignKeys < ActiveRecord::Migration
  def self.up
    load 'db/fixes/fix_activities_with_broken_foreign_keys.rb'
  end

  def self.down
    puts 'ireversible migration (data fix)'
  end
end
