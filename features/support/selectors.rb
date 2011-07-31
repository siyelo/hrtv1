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

    when /the budget coding tab/
      "#tab1"

    when /the budget districts tab/
      "#tab2"

    when /the budget cost categorization tab/
      "#tab3"

    when /the expenditure coding tab/
      "#tab5"

    when /the expenditure districts tab/
      "#tab6"

    when /the expenditure cost categorization tab/
      "#tab7"

    when /the main nav/
      "#main-nav"

    when /the sub nav/
      "#sub-nav"

    when /the admin nav/
      "#admin"

    when /the group tab/
      "ul#group"

    else
      raise "Can't find mapping from \"#{scope}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelper)
