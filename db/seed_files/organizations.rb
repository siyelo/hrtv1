Organization.delete_all

print "\n Seeding organizations for kenya"
FasterCSV.foreach("db/seed_files/organizations.csv", :headers=>true) do |row|
  organization = Organization.new(:name => row["name"])
  organization.raw_type = row["raw_type"]
  organization.acronym  = row["acronym"]
  organization.save!
  print "."
end
print "\n Finished Seeding organizations for kenya"
