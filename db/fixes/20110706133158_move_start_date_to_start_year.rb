data_request = DataRequest.all
data_request.each do |dr|
  dr.start_year = dr.start_date.strftime('%Y')
  dr.save
end