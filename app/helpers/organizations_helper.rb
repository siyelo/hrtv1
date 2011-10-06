module OrganizationsHelper
  def organization_response(data_request, organization)
    data_request.data_responses.detect { |dr| dr.organization_id == organization.id }
  end
end
