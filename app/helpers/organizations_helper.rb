module OrganizationsHelper
  def organization_response(organization)
    organization.data_responses.detect { |dr| dr.organization_id == organization.id }
  end

  def organization_activity_managers(organization)
    User.all.select { |u| u.roles.include?('activity_manager') && u.organizations.include?(organization) }
  end
end
