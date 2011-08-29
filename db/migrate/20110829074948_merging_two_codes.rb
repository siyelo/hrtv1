class MergingTwoCodes < ActiveRecord::Migration
  def self.up
    load "db/fixes/20110829_classifications_merging_fix.rb"
  end

  def self.down
      puts "IRREVERSIBLE MIGRATION"
  end
end
