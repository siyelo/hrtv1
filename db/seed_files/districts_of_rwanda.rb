puts "\nloading districts"

population_col = 2
district_col   = 7

FasterCSV.foreach("db/seed_files/districts_of_rwanda.csv", :headers => true) do |row|
  name = row[district_col].capitalize

  old_location          = Location.find_by_short_display(name)
  raise "No location found for #{name}" unless old_location

  district              = District.find_or_create_by_name(name)
  district.population   = row[population_col]
  district.old_location = old_location
  district.save!
end
