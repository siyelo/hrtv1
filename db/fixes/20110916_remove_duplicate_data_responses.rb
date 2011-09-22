def delete_response(response_id)
  data_response = DataResponse.find_by_id(response_id)

  if data_response
    data_response.projects.reload
    data_response.activities.reload
  end

  if data_response && data_response.empty? &&
    data_response.organization.data_responses(:all,
      :conditions => ["data_request_id = ?", data_response.data_request_id]).length > 2

      current_responses = data_response.organization.users.map(&:data_response_id_current)

      unless current_responses.include?(response_id)
        data_response.destroy
        puts "Removed duplicate response #{response_id}"
      end
  end
end

def merge_responses(from, to)
  from_response = DataResponse.find_by_id from
  to_response = DataResponse.find_by_id to
  if from_response && to_response
    from_response.projects.each do |project|
      project.data_response = to_response
      project.save(false)
    end

    from_response.activities.each do |activity|
      activity.data_response = to_response
      activity.save(false)
    end

    delete_response(from_response.reload.id)
  end
end

[9380, 9409, 9487, 9488, 9388, 9387, 7082, 9471,
    9338, 8531, 9507, 9193, 9509, 9510].each do |response_id|
  delete_response(response_id)
end

merge_responses(8501, 9379)
merge_responses(9410, 8293)





## DEBUG
organizations = Organization.find(:all, :include => :data_responses).select{|o| o.data_responses.length > 2}
if organizations.present?
  organizations.each do |organization|
    organization.data_responses.
      group_by { |o| o.data_request_id }.each do |data_request_id, data_responses|
      data_responses.each do |data_response|
        puts "#{organization.name} - #{data_request_id} - #{data_response.id} - #{data_response.empty?} #{organization.users.map(&:data_response_id_current).join(', ')}"
      end
    end
  end
else
  puts "No more duplicate responses"
end
