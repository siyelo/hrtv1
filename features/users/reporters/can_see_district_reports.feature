Feature: Reporter can see district reports
  In order to view data in my district
  As an Reporter
  I want to be able to see a district reports

  Background:
    Given an organization exists with name: "Organization1"
      And a data_request exists with title: "dr1", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization
      And an organization exists with name: "ORG"
      And a location exists with short_display: "Bugesera"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization, location: the location
      And a project exists with data_response: the data_response
      And a activity exists with name: "Activity1", data_response: the data_response, project: the project
      And a coding_spend_district exists with code: the location, activity: the activity
    When I am signed in as "reporter@hrtapp.com"

  Scenario: See reports overview
    When I follow "Reports"
      And I follow "Review District Expenditures and Current Budgets"
      And I follow "Bugesera"
    Then I should see "Bugesera"

  Scenario: See all organizations report
    When I follow "Reports"
      And I follow "Review District Expenditures and Current Budgets"
      And I follow "Bugesera"
      And I follow "View all Organizations"
    Then I should see "Organizations"

  Scenario: See single organization report
    When I follow "Reports"
      And I follow "Review District Expenditures and Current Budgets"
      And I follow "Bugesera"
      And I follow "Organization1"
    Then I should see "Organization: Organization1"

  Scenario: See all activities report
    When I follow "Reports"
      And I follow "Review District Expenditures and Current Budgets"
      And I follow "Bugesera"
      And I follow "View all Activities"
    Then I should see "Activities"

  Scenario: See single activity report
    When I follow "Reports"
      And I follow "Review District Expenditures and Current Budgets"
      And I follow "Bugesera"
      And I follow "Activity1"
    Then I should see "Activity: Activity1"
