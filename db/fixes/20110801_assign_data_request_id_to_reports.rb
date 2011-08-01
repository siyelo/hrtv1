data_request = DataRequest.find_by_title("FY2010 Workplan and FY2009 Expenditures")

if data_request
  print 'Updating data request ids for existing reports... '

  Report.all.each do |report|
    report.data_request = data_request
    report.save(false)
  end

  puts 'updated!'
else
  puts 'DATA REQUEST: "FY2010 Workplan and FY2009 Expenditures" NOT FOUND !!!'
end

