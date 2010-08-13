puts "\n  loading beneficiaries"
Beneficiary.delete_all
FasterCSV.foreach("db/seed_files/beneficiaries.csv", :headers=>true) do |row|
  c=nil #ActivityCostCategory.first( :conditions => {:id =>row[:id]}) implement update later
  if c.nil?
    c=Beneficiary.new
  end
  #puts row.inspect
  %w[short_display].each do |field|
    #puts "#{field}: #{row[field]}"
    c.send "#{field}=", row[field]
  end
  puts "error on #{row}" unless c.save
end