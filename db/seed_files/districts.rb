puts "loading locations (districts)"
Location.delete_all
FasterCSV.foreach("db/seed_files/districts.csv", :headers=>true) do |row|
  c=nil #Location.first( :conditions => {:id =>row[:id]}) implement update later
  if c.nil?
    c=Location.new
  end
  #puts row.inspect
  %w[short_display].each do |field|
    #puts "#{field}: #{row[field]}"
    c.send "#{field}=", row[field].strip
  end
  puts "error on #{row}" unless c.save
end