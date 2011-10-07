module OrganizationsHelper
  def organization_response(organization)
    organization.data_responses.detect { |dr| dr.organization_id == organization.id }
  end
end
