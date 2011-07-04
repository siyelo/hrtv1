Feature: Can view district reports
  In order to reduce admin costs
  As a user
  I want to be able to see reports by district

  Background:
    Given a code exists with short_display: "Code X"
      And a code exists with short_display: "Code Y"
      And an organization exists with name: "GoR"

      And a data_request exists with title: "Req1", organization: the organization
      And a data_request exists with title: "Req2", organization: the organization

      And an organization exists with name: "Org A"
      And a reporter exists with username: "reporter", organization: the organization
      And a data_response exists with data_request: the 1st data_request, organization: the organization
      And a project exists with name: "Project 1 A", data_response: the data_response
      And an activity exists with name: "Activity 1 A", data_response: the data_response, project: the project
      And a location exists with short_display: "Location X"
      And a district exists with old_location: the location
      And the location is one of the activity's locations
      And a location exists with short_display: "Location Y"
      And a district exists with old_location: the location
      And the location is one of the activity's locations
      And a coding_budget exists with activity: the activity, code: the first code
      And a coding_budget exists with activity: the activity, code: the 2nd code
      And a coding_spend exists with activity: the activity, code: the first code
      And a coding_spend exists with activity: the activity, code: the 2nd code
      And a coding_budget_district exists with activity: the activity, code: the first location
      And a coding_spend_district exists with activity: the activity, code: the first location

      And an organization exists with name: "Org B"
      And a data_response exists with data_request: the 1st data_request, organization: the organization
      And a project exists with name: "Project 1 B", data_response: the data_response
      And an activity exists with name: "Activity 1 B", data_response: the data_response, project: the project
      And the location is one of the activity's locations
      And a coding_budget exists with activity: the activity, code: the first code
      And a coding_budget exists with activity: the activity, code: the 2nd code
      And a coding_spend exists with activity: the activity, code: the first code
      And a coding_spend exists with activity: the activity, code: the 2nd code
      And a coding_budget_district exists with activity: the activity, code: the first location
      And a coding_spend_district exists with activity: the activity, code: the first location

      And an organization exists with name: "Org C"
      And a data_response exists with data_request: the 2nd data_request, organization: the organization
      And a project exists with name: "Project 2 A", data_response: the data_response
      And an activity exists with name: "Activity 2 A", data_response: the data_response, project: the project
      And the location is one of the activity's locations
      And a coding_budget exists with activity: the activity, code: the first code
      And a coding_budget exists with activity: the activity, code: the 2nd code
      And a coding_spend exists with activity: the activity, code: the first code
      And a coding_spend exists with activity: the activity, code: the 2nd code
      And a coding_budget_district exists with activity: the activity, code: the first location
      And a coding_spend_district exists with activity: the activity, code: the first location

#' damn Cucumber TM syntax highlighting

  Scenario: reporter views district reports
    Given I am signed in as "reporter"
    And I follow "Req1"
    When I drill down to Reports->Districts->"Location X"->"Activity 1 A"
    Then I should see a District-Location-Activity report for "Activity 1 A"

  Scenario: admin views district reports for all organizations
    Given I am signed in as a sysadmin
    And I follow "Req1"
    When I drill down to Reports->Districts->"Location X"->"Activity 1 A"
    Then I should see a District-Location-Activity report for "Activity 1 A"
    When I drill down to Reports->Districts->"Location X"->"Activity 1 B"
    Then I should see a District-Location-Activity report for "Activity 1 B"

  # District reports are the same for all users and organizations
  Scenario: admin views district reports for single organization
    Given I am signed in as a sysadmin
    And I follow "Req1"
    When I follow "Organizations"
    And I follow "Org A"
    When I drill down to Reports->Districts->"Location X"->"Activity 1 A"
    Then I should see a District-Location-Activity report for "Activity 1 A"
    When I drill down to Reports->Districts->"Location X"->"Activity 1 B"
    Then I should see a District-Location-Activity report for "Activity 1 B"

  Scenario: user only sees district reports for current request
    Given I am signed in as "reporter"
    And I follow "Req1"
    And I follow "Reports"
    And I follow "Review District Expenditures and Current Budgets"
    And I follow "Location X"
    And I follow "View all Activities"
    Then I should not see "Activity 2 A"

