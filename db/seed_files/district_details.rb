# Districts seed depends on existing locations in database
# You will need to run this file after locations exist in codes table

print "\nloading districts "

population_col = 2
district_col   = 7

FasterCSV.foreach("db/seed_files/district_details.csv", :headers => true) do |row|
  begin
    print '.'
    name = row[district_col].capitalize

    old_location          = Location.find_by_short_display(name)
    raise "No location found for #{name}".to_yaml unless old_location

    district              = District.find_or_create_by_name(name)
    district.population   = row[population_col]
    district.old_location = old_location
    district.save!
  rescue
    puts "ERROR: Location is missing - ignore if you will seed the db #{$!}"
  end
end

puts "\n\n"
