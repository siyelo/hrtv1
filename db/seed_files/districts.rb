puts "\nloading locations (districts)"

Location.delete_all

case ENV['HRT_COUNTRY']
when 'kenya'
  print "\n Seeding districts for kenya"
  FasterCSV.foreach("db/seed_files/kenya/districts.csv", :headers=>true) do |row|
    name = row["short_display"].capitalize
    population = row["population"].to_i
    Location.create!(:short_display => name)
    District.create!(:name => name, :population => population)
    print "."
  end
else
  # TODO move files to rwanda directory like kenya above
  print "\n Seeding districts for rwanda"
  FasterCSV.foreach("db/seed_files/districts.csv", :headers=>true) do |row|
    Location.create!(:short_display => row[0].strip)
    print "."
  end
  load 'db/seed_files/district_details.rb'
end
