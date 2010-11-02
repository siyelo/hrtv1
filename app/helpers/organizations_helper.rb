module OrganizationsHelper
  def organization_name_w_num_users organization
      "#{organization.name} - #{organization.users.count} users"
  end
end
