@run
Feature: Reporter can see dashboard
  In order to improve data quality
  A reporter can see prompt to review data, when Request is in final review stage

  Background:
    Given an organization exists with name: "WHO"
      And a data_request exists with title: "Req1", final_review: true, organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization

    @javascript
    Scenario: Prompted to review incomplete data
      When I am signed in as "reporter@hrtapp.com"
        And I go to the dashboard
      # Req1
      When I hover over ".tooltip" within ".modern_table tbody tr:nth-child(1)"
      Then I should see "This Request is in the Final Review stage."

    @javascript
    Scenario: Prompted to review incomplete data for each incomplete request
      When a data_request exists with title: "Req2", final_review: true, organization: the organization
        And a data_response should exist with data_request: the data_request, organization: the organization
        And I am signed in as "reporter@hrtapp.com"
        And I go to the dashboard
      # Req2
      When I hover over ".tooltip" within ".modern_table tbody tr:nth-child(1)"
      Then I should see "This Request is in the Final Review stage."
      # Req1
      When I hover over ".tooltip" within ".modern_table tbody tr:nth-child(2)"
      Then I should see "This Request is in the Final Review stage."

    @javascript
    Scenario: Prompted to review incomplete data for each incomplete request
      When a data_request exists with title: "Req2", final_review: false, organization: the organization
        And a data_response should exist with data_request: the data_request, organization: the organization
        And I am signed in as "reporter@hrtapp.com"
        And I go to the dashboard
      # Req2
      When I hover over ".tooltip" within ".modern_table tbody tr:nth-child(1)"
      Then I should see "This Request is in the Final Review stage."
      # Req1
      When I hover over ".tooltip" within ".modern_table tbody tr:nth-child(2)"
      Then I should not see "This Request is in the Final Review stage." within ".modern_table tbody tr:nth-child(2)"
