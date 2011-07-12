Feature: Admin can review country
  In order to reduce costs
  As an admin
  I want to be able to see country review screen

  Background:
    Given a mtef_code exists with short_display: "Code A"
      And a mtef_code exists with short_display: "Code B"
      And an organization exists with name: "GoR"
      And a data_request exists with title: "Req1", organization: the organization
      And an organization exists with name: "UNDP"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a data_response exists with data_request: the data_request, organization: the organization
      And a project exists with name: "Project A", data_response: the data_response
      And an activity exists with name: "Activity A", data_response: the data_response, project: the project
      And a location exists with short_display: "Location A"
      And the location is one of the activity's locations
      And a location exists with short_display: "Location B"
      And the location is one of the activity's locations
      And a coding_budget exists with activity: the activity, code: the first mtef_code
      And a coding_budget exists with activity: the activity, code: the 2nd mtef_code
      And a coding_spend exists with activity: the activity, code: the first mtef_code
      And a coding_spend exists with activity: the activity, code: the 2nd mtef_code
      And a coding_budget_district exists with activity: the activity, code: the first location
      And a coding_spend_district exists with activity: the activity, code: the first location


    Scenario: "Log in as admin, go to district activity detail screen"
      Given I am signed in as a sysadmin
      When I follow "Reports"
        And I follow "Review National Expenditures and Current Budgets"
        And I follow "View all Activities"
      Then I should see "Activities" within "h1"

      When I follow "Activity A"
      Then I should see "Activity A" within "h1"
        And I should see "NSP Expenditure"
        And I should see "NSP Current Budget"
