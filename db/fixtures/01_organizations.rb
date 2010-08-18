puts "\nLoading organizations"

#puts "  Removing existing orgs"
#Organization.delete_all

puts "  Loading organizations.csv"

# Expected format
# <Name>, <Raw Type>, <District>

i = 1
FasterCSV.foreach("db/fixtures/files/organizations.csv", :headers => true ) do |row|
  i = i + 1
  name = row[0].try(:strip)
  org = Organization.find_or_create_by_name name

  org.raw_type = row[1].try(:strip)
  if org.raw_type != "Donors"
    org.type = "Ngo"
  elsif org.raw_type == "Donors"
    org.type = "Donor"
  end

  unless row[2].blank?
    district = row[2].downcase.capitalize.strip
    district = Location.find_by_short_display(district)
    puts "WARN: District \"#{district}\" not found (row: \##{i})" if district.nil?
    org.locations << district
    org.type = nil
  end

  puts "Creating org #{org.name}, #{org.type}, #{org.locations}\n"
  #print "."
  puts "error on #{row}" unless org.save

end
puts "...Loading organizations DONE\n"
