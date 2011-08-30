class RoundingCodeAssignmentsToTwoDecimals < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110730_code_assignments_two_decimals.rb'
  end

  def self.down
    puts "IRREVERSIBLE MIGRATION"
  end
end
