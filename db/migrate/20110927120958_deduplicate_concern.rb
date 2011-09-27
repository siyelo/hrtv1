class DeduplicateConcern < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110927_merge_concern_worldwide.rb'
  end

  def self.down
    puts "IRREVERSIBLE MIGRATION"
  end
end
