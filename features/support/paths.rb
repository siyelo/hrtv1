module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the data response page for "(.+)"/
      req = DataRequest.find_by_title($1)
      edit_response_path( DataResponse.find_by_data_request_id req.id)

    when /the reporter dashboard page/
      reporter_dashboard_path

    when /the projects page for response "(.+)" org "(.+)"/
      req = DataRequest.find_by_title($1)
      response = Organization.find_by_name($2).data_responses.find_by_data_request_id(req)
      response_projects_path(response)

    when /the new project page for response "(.+)" org "(.+)"/
      req = DataRequest.find_by_title($1)
      response = Organization.find_by_name($2).data_responses.find_by_data_request_id(req)
      new_response_project_path(response)

    when /the activities page/
      activities_path

    when /the classifications page/
      classifications_path

    when /the comments page/
      comments_path

    when /the organizations page/
      organizations_path

    when /the login page/
      login_path

    when /the implementers page/
      implementers_path

    when /the other costs page/
      other_costs_path

    when /the budget classification page for "(.+)"/
      activity = Activity.find_by_name($1)
      activity_code_assignments_path(activity)

    when /the activity classification page for "(.+)"/
      activity = Activity.find_by_name($1)
      activity_code_assignments_path(activity)

    when /the user guide page/
      static_page_path(:user_guide)

    when /the admin review data response page for organization "(.+)", request "(.+)"/
      response = get_data_response($2, $1)
      admin_response_path(response)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
