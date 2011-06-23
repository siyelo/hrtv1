DataRequest.all.each do |data_request|
  Organization.all.each do |organization|
    dr = organization.data_responses.find(:first,
      :conditions => {:data_request_id => data_request.id})
    unless dr
      dr = organization.data_responses.new
      dr.data_request = data_request
      dr.save!
      puts "Created response for organization: #{organization.name} request: #{data_request.title}"
    end
  end
end
