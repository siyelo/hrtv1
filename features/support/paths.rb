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

    when /the ngo dashboard page/
      static_page_path(:ngo_dashboard)

    when /the projects listing page/
      projects_path

    when /the projects page/
      projects_path

    when /the activities page/
      activities_path

    when /the activity classification page for "(.+)"/
      a = Activity.find_by_name($1)
      manage_code_assignments_path(a)

    when /the login page/
      login_path

    when /the funding sources page/
      funding_sources_data_entry_path

    when /the providers page/
      providers_data_entry_path

    when /the other costs page/
      other_costs_path

    when /the budget classification page for "(.+)"/
      activity = Activity.find_by_name($1)
      activity_budget_path(activity)

    when /the expenditure classification page for "(.+)"/
      activity = Activity.find_by_name($1)
      activity_expenditure_path(activity)

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
