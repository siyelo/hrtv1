Feature: Reporter can see dashboard
  In order to see latest news
  As a reporter
  I want to be able to see a dashboard for relevant activities

  Background:
    Given an organization exists with name: "WHO"
      And a data_request exists with title: "dr1", organization: the organization
      And a data_request exists with title: "dr2", organization: the organization
      And an organization exists with name: "ORG"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization
      And I am signed in as "reporter@hrtapp.com"

    Scenario: "See data requests"
      Then I should see "Dashboard"
      And I should see "Data Requests"
      Then I should see "dr1" within "#content"
       And I should see "dr2" within "#content"

    Scenario: See menu tabs when a Data Req is selected
      Then I should see "Home" within the main nav
        And I should see "Projects" within the main nav
        And I should see "Reports" within the main nav
        And I should see "Settings" within the main nav

    Scenario: Can Switch between requests
      Then I should see "ORG: [dr2]"
      When I follow "dr1"
      Then I should see "ORG: [dr1]"
