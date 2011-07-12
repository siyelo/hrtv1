Feature: Reporter can see dashboard
  In order to see latest news
  As a reporter
  I want to be able to see a dashboard for relevant activities

  Background:
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And a reporter exists with email: "reporter@hrtapp.com", organization: the organization

    Scenario: "See data requests"
      Given I am signed in as "reporter@hrtapp.com"
      Then I should see "Dashboard"
      And I should see "Data Requests"


    Scenario: See menu tabs when a Data Req is selected
      Given I am signed in as "reporter@hrtapp.com"
      Then I should see "Home" within the main nav
        And I should see "Projects" within the main nav
        And I should see "Reports" within the main nav
        And I should see "Settings" within the main nav


    Scenario: See unfulfilled/current Data Requests listed
      Given an organization exists with name: "WHO"
        And a data_request exists with title: "Req2", organization: the organization
        And a data_request exists with title: "Req1", organization: the organization
        And an organization exists with name: "UNAIDS"
        And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
        And a data_response exists with data_request: the data_request, organization: the organization
        And I am signed in as "reporter@hrtapp.com"
      When I go to the dashboard
      Then I should see "Req1" within "#content"
        And I should see "Req2" within "#content"
