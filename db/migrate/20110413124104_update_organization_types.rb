class UpdateOrganizationTypes < ActiveRecord::Migration
  def self.up
    FasterCSV.foreach("db/fixes/update_org_types.csv", :headers=>true) do |row|
      o = Organization.find_by_name(row[0])
      o.update_attributes(:raw_type => row[1])
    end
  end
   
  def self.down
    puts "irreversible migration - data fix"
  end
end
