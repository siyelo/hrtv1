Feature: Activity Manager can login
  In order to protect information
  As an Activity Manager
  I want to be able to login

  Background:
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And a reporter exists with username: "reporter", organization: the organization


    Scenario: Login as an activity manager with a username
        Given I go to the login page
        And I fill in "Username or Email" with "reporter"
        And I fill in "Password" with "password"
      When I press "Sign in"
      Then I should be on the reporter dashboard page
        And I should see the reporters admin nav
        And I should see the main nav tabs
