class ActivityBelongsToProjectFix < ActiveRecord::Migration
  def self.up
    load "db/fixes/20110310_activity_belongs_to_project_fix.rb"
  end

  def self.down
  end
end
