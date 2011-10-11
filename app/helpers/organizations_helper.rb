module OrganizationsHelper
  def organization_response(organization, data_request)
    organization.data_responses.detect { |dr| dr.data_request == data_request }
  end

  def organization_activity_managers(organization)
    User.all.select { |u| u.roles.include?('activity_manager') && u.organizations.include?(organization) }
  end
end
