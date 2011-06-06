module AppHelpers
  def get_data_response(data_request_name, organization_name)
    data_request = DataRequest.find_by_title(data_request_name)
    organization = Organization.find_by_name(organization_name)
    DataResponse.find(:first, :conditions => ["data_request_id = ? AND organization_id = ?", data_request.id, organization.id])
  end
end

World(AppHelpers)
