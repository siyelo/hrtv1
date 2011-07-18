module Admin::OrganizationsHelper
  def organization_name_w_num_users(organization)
    "#{organization.name} - #{pluralize(organization.users_count, 'user')}"
  end

  def search_and_filter_message(count, query, filter)
    message = "Found #{pluralize(count, "organization")}"
    if query
      message += " matching <span class='bold'>#{query}</span>"
    end
    if filter && filter != "All"
      message += " with a <span class='bold'>#{filter}</span> response"
    end

    if query || filter
      message += ". #{link_to "(Back to all organizations)", admin_organizations_url}"
    end

    message
  end
end


