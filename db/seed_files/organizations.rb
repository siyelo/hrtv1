Organization.delete_all

case ENV['HRT_COUNTRY']
when 'kenya'
  print "\n Seeding organizations for kenya"
  FasterCSV.foreach("db/seed_files/kenya/organizations.csv", :headers=>true) do |row|
    organization = Organization.new(:name => row["name"])
    organization.raw_type = row["raw_type"]
    organization.old_type = row["old_type"]
    organization.acronym  = row["acronym"]
    organization.save
    print "."
  end
  print "\n Finished Seeding organizations for kenya"
else
   print "\n Seeding organizations for any other country"
   # TODO actually seed something
   # TODO standardize org types in different seed files
end
