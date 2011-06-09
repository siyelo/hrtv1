class ChangeCentralLevelToNationalLevel < ActiveRecord::Migration
  def self.up
    Location.reset_column_information
    code = Location.find(:first, :conditions => {:short_display => 'Central Level'})
    if code
      code.short_display = "National Level"
    else
      code = Location.new(:short_display => "National Level")
    end
      code.save!
  end

  def self.down
    Location.reset_column_information
    code = Location.find(:first, :conditions => {:short_display => 'National Level'})
    if code
      code.short_display = "Central Level"
      code.save!
    end
  end
end