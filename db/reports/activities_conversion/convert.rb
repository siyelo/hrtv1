require 'rubygems'
require 'fastercsv'

puts "Converting input.csv to output.csv"

csv = FasterCSV.generate do |csv|
  csv << ['Activity Detail', 'Provider', 'Description', 'Amount']

  provider = ''
  FasterCSV.foreach("input.csv", :headers => true) do |row|
    program     = row[0].to_s.strip
    agency      = row[1].to_s.strip
    sub_program = row[2].to_s.strip
    output      = row[3].to_s.strip
    amount      = row[4].to_s.strip

    if (sub_program == '' && output != '') || (sub_program != '' && output == '')
      if sub_program != ''
        parts = sub_program.split('(')
        description = parts[0].to_s.strip
        provider    = parts[1].to_s.strip.chop # chomp to remove the ending '('
      else
        description      = output
      end

      activity_detail  = output.to_s.strip == '' ? 'no' : 'yes'
      csv << [activity_detail, provider, description, amount]
    end
  end
end


File.open('output.csv', 'w') do |file|
  file.puts csv
end
