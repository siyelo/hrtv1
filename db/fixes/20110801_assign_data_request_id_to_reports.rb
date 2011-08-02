data_request = DataRequest.first

if data_request
  print 'Updating data request ids for existing reports... '

  Report.all.each do |report|
    report.data_request = data_request
    report.save(false)
  end

  puts 'updated!'
else
  puts 'DATA REQUEST NOT FOUND !!!'
end

