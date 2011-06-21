@run
Feature: Reporter can start a data response
  In order to enter data
  As a reporter
  I want to be able to start a data response


  Background:
    Given an organization exists with name: "organization1"
    And a data_request exists with title: "data_request1"
    And an organization "my_organization" exists with name: "organization2"
    And a data_response exists with data_request: the data_request, organization: organization "my_organization"
    And a reporter exists with username: "reporter", organization: organization "my_organization"
    And I am signed in as "reporter"

  Scenario: Reporter can start a data response
    When I follow "Dashboard"
      And I follow "Edit"
      And I select "Request 1" from "Data Request"
      And I press "Begin Response"
    Then I should see "Your response was successfully created."
