module Admin::OrganizationsHelper
  def organization_name_w_num_users(organization)
    "#{organization.name} - #{pluralize(organization.users_count, 'user')}"
  end
end


