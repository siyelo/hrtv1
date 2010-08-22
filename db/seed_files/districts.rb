puts "\nloading locations (districts)"

Location.delete_all

FasterCSV.foreach("db/seed_files/districts.csv", :headers=>true) do |row|
  Location.create!(:short_display => row[0].strip)
  print "."
end