data_request = DataRequest.all
data_request.each do |dr|
  dr.purposes = true
  dr.locations = true
  dr.inputs = true
  dr.service_levels = true
  dr.year_q2 = true
  dr.year_q3 = true
  dr.year_q4 = true
  dr.year_q5 = true
  dr.save(false) # Save without validations
end
