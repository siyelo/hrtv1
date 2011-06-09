class AddCentralLevelLocation < ActiveRecord::Migration
  def self.up
    Location.reset_column_information
    code = Location.new(:short_display => "Central Level")
    code.save!
  end

  def self.down
    puts "irreversible migration"
  end
end
