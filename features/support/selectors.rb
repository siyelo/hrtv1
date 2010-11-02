# http://bjeanes.com/2010/09/19/selector-free-cucumber-scenarios
module HtmlSelectorsHelper
  def selector_for(scope)
    case scope

    when /the body/
      "html > body"

    when /the selected data response sub-tab/
      "#data_response_sub_tabs.tabs_nav ul li.selected"

    when /the selected project sub-tab/
      ".project_sub_tabs.tabs_nav ul li.selected"

    when /the selected activity sub-tab/
      ".activity_sub_tabs.tabs_nav ul li.selected"

    else
      raise "Can't find mapping from \"#{scope}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelper)