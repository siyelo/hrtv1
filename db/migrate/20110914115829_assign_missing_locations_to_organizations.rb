class AssignMissingLocationsToOrganizations < ActiveRecord::Migration
  def self.up
    load "db/fixes/20110914_assign_missing_locations_to_organizations.rb"
  end

  def self.down
    puts "IRREVERSIBLE MIGRATION"
  end
end
