Organization.delete_all

case ENV['HRT_COUNTRY']
when 'kenya'
  print "\n Seeding organizations for kenya"
  FasterCSV.foreach("db/seed_files/kenya/organization.csv", :headers=>true) do |row|
    name = row["name"]
    raw_type = row["raw_type"]
    Organization.create!(:name => name, :raw_type => raw_type)
    print "."
  end
  print "\n Finished Seeding organizations for kenya"
else
   print "\n Seeding organizations for rwanda"
end