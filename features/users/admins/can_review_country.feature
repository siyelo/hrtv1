Feature: Admin can review country
  In order to reduce costs
  As an admin
  I want to be able to see country review screen

Background:
  Given a code exists with short_display: "Code A"
  And a code exists with short_display: "Code B"
  And an organization exists with name: "GoR"
  And a data_request exists with title: "Req1", requesting_organization: the organization
  And an organization exists with name: "UNDP"
  And a reporter exists with username: "undp_user", organization: the organization
  And a data_response exists with data_request: the data_request, responding_organization: the organization
  And a project exists with name: "Project A", data_response: the data_response
  And an activity exists with name: "Activity A", data_response: the data_response
  And the project is one of the activity's projects
  And a location exists with short_display: "Location A"
  And the location is one of the activity's locations
  And a location exists with short_display: "Location B"
  And the location is one of the activity's locations
  And a coding_budget exists with activity: the activity, code: the first code
  And a coding_budget exists with activity: the activity, code: the 2nd code
  And a coding_spend exists with activity: the activity, code: the first code
  And a coding_spend exists with activity: the activity, code: the 2nd code
  And a coding_budget_district exists with activity: the activity, code: the first location
  And a coding_spend_district exists with activity: the activity, code: the first location
  And "Code A" and "Code B" are fake Mtef roots

@country_review
Scenario: "Log in as admin, go to district activity detail screen"
  Given I am signed in as an admin
  When I follow "Dashboard"
  And I follow "Review National Expenditures and Budgets"
  And I follow "View all Activities"
  Then I should see "Activities" within "h1"
  When I follow "Activity A"
  Then I should see "Activity A" within "h1"
  And I should see "NSP Spent"
  And I should see "NSP Budget"
