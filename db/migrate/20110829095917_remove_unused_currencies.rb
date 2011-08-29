class RemoveUnusedCurrencies < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110829_remove_unused_currencies.rb'
  end

  def self.down
    puts "IRREVERSIBLE MIGRATION"
  end
end
