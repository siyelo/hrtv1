module Admin::OrganizationsHelper

  def organization_name_w_num_users(organization)
    "#{friendly_name(organization, 255)} - #{pluralize(organization.users_count, 'user')}"
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
      message += ". #{link_to "(Back to all reporting organizations)", admin_organizations_url}"
    end

    message
  end

  def select_with_all_orgs_plus_user_count(orgs)
    options_for_select(orgs.map{ |o| [organization_name_w_num_users(o), o.id] })
  end
end


