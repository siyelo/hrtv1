# fix those fstreams that didnt get their amounts zeroed when cloned from previous response.

new_request = DataRequest.find_by_title '2010 Expenditures and 2011 Budget'

streams = FundingStream.find :all,
  :conditions => ["date(updated_at) = ? AND
    project_id in 
      (SELECT projects.id 
         FROM projects 
         INNER JOIN data_responses ON data_responses.id = projects.data_response_id
         INNER JOIN data_requests ON
                data_requests.id = data_responses.data_request_id AND
                data_requests.id = #{new_request.id}
      )", Date.parse('2011-06-06')]
      
      
streams.each do |s|
  s.budget = s.spend = s.budget_in_usd = s.spend_in_usd = 0.0
  s.save
end