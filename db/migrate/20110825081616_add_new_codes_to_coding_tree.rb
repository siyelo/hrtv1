class AddNewCodesToCodingTree < ActiveRecord::Migration
  def self.up
    Code.reset_column_information
    if Rails.env != "test"
      load 'db/fixes/20110825_add_new_codes.rb'
    end
  end

  def self.down
    puts "IRREVERSIBLE MIGRATION!"
  end
end
