class AddNewCodesToCodingTree < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110825_add_new_codes.rb'
  end

  def self.down
    puts "IRREVERSIBLE MIGRATION!"
  end
end
