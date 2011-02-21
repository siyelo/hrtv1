d = DataRequest.find_by_title("FY2010 Workplan and FY2009 Expenditures")
if d
  d.due_date = Date.new(2010, 9, 1)
  d.organization = Organization.find_by_name 'Ministry of Health'
  d.save!
  puts "Successfully updated: FY2010 Workplan and FY2009 Expenditures"
else
  puts 'WARN - could not find Request: "FY2010 Workplan and FY2009 Expenditures"'
end