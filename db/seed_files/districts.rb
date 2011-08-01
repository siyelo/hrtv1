puts "\nloading locations (districts)"

Location.delete_all

print "\n Seeding districts for kenya"
FasterCSV.foreach("db/seed_files/districts.csv", :headers=>true) do |row|
  name = row["short_display"].capitalize
  population = row["population"].to_i
  Location.create!(:short_display => name)
  District.create!(:name => name, :population => population)
  print "."
end
