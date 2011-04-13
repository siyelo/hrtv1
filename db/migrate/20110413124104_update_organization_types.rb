class UpdateOrganizationTypes < ActiveRecord::Migration
  def self.up
    FasterCSV.foreach("db/fixes/update_org_types.csv", :headers=>true) do |row|
      puts row[1]
      o = row[0].blank? ? Organization.find_by_name(row[1]) : Organization.find(row[0])
      o.update_attributes(:raw_type => row[2])
    end
  end
   
  def self.down
    puts "irreversible migration - data fix"
  end
end
