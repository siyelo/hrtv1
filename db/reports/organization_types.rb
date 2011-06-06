require 'fastercsv'

orgs = Organization.all

csv = FasterCSV.generate do |csv|
  # header
  row = ["organization_id", "organization_name", "organization_type"]

  csv << row

  # data
  orgs.each do |org|
    row = [org.id,
           org.name,
           org.raw_type
          ]
    csv << row
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'organization_types.csv'), 'w') do |file|
  file.puts csv
end

