puts "\nloading locations (districts)"

Location.delete_all

case ENV['HRT_COUNTRY']
when 'rwanda'
  print "\n Seeding districts for rwanda"
  FasterCSV.foreach("db/seed_files/districts.csv", :headers=>true) do |row|
    Location.create!(:short_display => row[0].strip)
    print "."
  end
  load 'db/seed_files/districts_of_rwanda.rb'
when 'kenya'
  print "\n Seeding districts for kenya"
  FasterCSV.foreach("db/seed_files/kenya/districts.csv", :headers=>true) do |row|
    name = row["short_display"].capitalize
    population = row["population"].to_i
    District.create!(:name => name, :population => population)
    print "."
  end
else
  print "\n Seeding districts for rwanda"
  FasterCSV.foreach("db/seed_files/districts.csv", :headers=>true) do |row|
    Location.create!(:short_display => row[0].strip)
    print "."
  end
  load 'db/seed_files/districts_of_rwanda.rb'
end