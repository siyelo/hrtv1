module NavigationHelpers
  include ApplicationHelper

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

    when /the dashboard/
      dashboard_path

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

    when /the admin comments page/
      admin_comments_path

    when /the comments page/
      comments_path

    when /the organizations page/
      organizations_path

    when /the login page/
      login_path

    when /the implementers page/
      implementers_path

    when /the purpose split page for "(.+)"/
      activity = Activity.find_by_name($1)
      edit_activity_or_ocost_path(activity, :mode => 'purposes')

    when /the location split page for "(.+)"/
      activity = Activity.find_by_name($1)
      edit_activity_or_ocost_path(activity, :mode => 'locations')

    when /the input split page for "(.+)"/
      activity = Activity.find_by_name($1)
      edit_activity_or_ocost_path(activity, :mode => 'inputs')

    when /the output edit page for "(.+)"/
      activity = Activity.find_by_name($1)
      edit_activity_or_ocost_path(activity, :mode => 'outputs')

   when /the edit project page for related activity "(.+)"/
      activity = Activity.find_by_name($1)
      edit_response_project_path(activity.response, activity.project)

    when /the admin review data response page for organization "(.+)", request "(.+)"/
      response = get_data_response($2, $1)
      admin_response_path(response)

    when /the set request page for "(.+)"/
      request = DataRequest.find_by_title($1)
      set_request_path(request.id)

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
