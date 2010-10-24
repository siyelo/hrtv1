# Expected format
# <Name>, <Raw Type>, <District>
i = 1
FasterCSV.foreach("db/fixtures/files/organizations.csv", :headers => true ) do |row|
  i = i + 1
  name = row[0].try(:strip)
  org = Organization.find_or_create_by_name name
  puts "Found existing org #{org.id}" if org.id

  org.raw_type = row[1].try(:strip)
  if org.raw_type != "Donors"
    org.type = "Ngo"
  elsif org.raw_type == "Donors"
    org.type = "Donor"
  end

  if !row[2].blank? or org.raw_type == "District"
    # TODO allow be in multiple districts
    district = row[2].downcase.capitalize.strip unless row[2].blank?
    district ||= org.name.gsub(/District of /, '')
    district = Location.find_by_short_display(district)
    puts "WARN: District \"#{district}\" not found (row: \##{i})" if district.nil?
    org.locations.delete_all
    org.locations << district
    org.type = nil
  end

  unless row[3].blank?
    org.fosaid = row[3]
  end

  puts "Creating org #{org.name}, #{org.type}, #{org.locations}\n"
  #print "."
  puts "error on #{row}" unless org.save

end

