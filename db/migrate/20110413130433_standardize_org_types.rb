class StandardizeOrgTypes < ActiveRecord::Migration
  def self.up
    FasterCSV.foreach("db/fixes/standardize_org_types.csv", :headers=>true) do |row|
      o = Organization.update_all("raw_type='#{row[1]}'", "raw_type='#{row[0]}'")
    end
  end

  def self.down
    puts "irreversible migration - data fix"
  end
end
