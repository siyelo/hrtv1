Organization.delete_all

print "\n Seeding organizations for kenya"
FasterCSV.foreach("db/seed_files/kenya/organizations.csv", :headers=>true) do |row|
  begin
    organization = Organization.new(:name => row["name"])
    organization.raw_type = row["raw_type"]
    organization.acronym  = row["acronym"]
    organization.save!
    print "."
  rescue => e
    p organization
    p organization.errors.full_messages
    raise e
  end
end
print "\n Finished Seeding organizations for kenya"
