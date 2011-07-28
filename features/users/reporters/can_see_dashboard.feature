Feature: Reporter can see dashboard
  In order to see latest news
  As a reporter
  I want to be able to see a dashboard for relevant activities

  Background:
  
  
  Scenario: "See data requests"
    Given a basic org + reporter profile, with data response, signed in
    Then I should see "Dashboard"
    And I should see "Dashboard"

  Scenario: See menu tabs when a Data Req is selected
    Given a basic org + reporter profile, with data response, signed in
      And I follow "Req1"
    Then I should see "Home" within the main nav
      And I should see "Projects" within the main nav
      And I should see "Settings" within the main nav
      And I should see "Reports" within the main nav


  Scenario: See unfulfilled/current Data Requests listed
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And a data_request exists with title: "data_request2"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And I am signed in as "reporter@hrtapp.com"
      Then I should see "data_request1"
      And I should see "data_request2"

