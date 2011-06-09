Feature: Admin can review districts
  In order to reduce costs
  As a sysadmin
  I want to be able to see district review screen

  Background:
    Given a code exists with short_display: "Code A"
      And a code exists with short_display: "Code B"
      And an organization exists with name: "GoR"
      And a data_request exists with title: "Req1", organization: the organization
      And an organization exists with name: "UNDP"
      And a reporter exists with email: "undp_user@hrtapp.com", organization: the organization
      And a data_response exists with data_request: the data_request, organization: the organization
      And a project exists with name: "Project A", data_response: the data_response
      And an activity exists with name: "Activity A", data_response: the data_response, project: the project
      And a location exists with short_display: "Location A"
      And a district exists with old_location: the location
      And the location is one of the activity's locations
      And a location exists with short_display: "Location B"
      And a district exists with old_location: the location
      And the location is one of the activity's locations
      And a coding_budget exists with activity: the activity, code: the first code
      And a coding_budget exists with activity: the activity, code: the 2nd code
      And a coding_spend exists with activity: the activity, code: the first code
      And a coding_spend exists with activity: the activity, code: the 2nd code
      And a coding_budget_district exists with activity: the activity, code: the first location
      And a coding_spend_district exists with activity: the activity, code: the first location


  Scenario: "Log in as admin, go to district activity detail screen"
    Given an organization exists with name: "SysAdmin Org"
    And a sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
    And I am signed in as "sysadmin@hrtapp.com"
    When I follow "Dashboard"
    And I follow "Review District Past Expenditures and Current Budgets"
    Then I should see "Review District Past Expenditures and Current Budgets" within "h1"
    And I follow "Location A"
    And I should see "Location A" within "h1"
    When I follow "View all Activities"
    Then I should see "Activities" within "h1"
    When I follow "Activity A"
    Then I should see "Activity A" within "h1"
    And I should see "Proportion Past Expenditure"
    And I should see "Proportion Current Budget"
    And I should see "NSP Past Expenditure"
    And I should see "NSP Current Budget"
