Feature: Reporter can login
  In order to protect information
  As a reporter
  I want to be able to login

  Background:
    Given an organization exists with name: "MoH"
      And a data_request exists with organization: the organization
      And an organization exists with name: "Some Donor"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization

  Scenario: See login form on homepage
    When I go to the home page
    Then I should see the visitors header
      And I should see the common footer

  Scenario: Login with invalid data - see flash message not AR errors
    When I go to the home page
      And I fill in "Email" with "not a real user"
      And I fill in "Password" with ""
      And I press "Sign in"
    Then I should see "Wrong Email or Password"
      And I should not see "There were problems with the following fields:"

  Scenario: Login as a reporter with email address
    When I go to the home page
      And I fill in "Email" with "reporter@hrtapp.com"
      And I fill in "Password" with "password"
      And I press "Sign in"
    Then I should see the reporters admin nav
      And I should see the main nav tabs
      And I should see "reporter@hrtapp.com"
      And I should be on the dashboard page
