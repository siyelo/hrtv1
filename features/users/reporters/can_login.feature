Feature: Reporter can login
  In order to protect information
  As a reporter
  I want to be able to login

  Scenario: Login via home page
    When I go to the home page
      And I follow "Sign in"
    Then I should be on the login page

  Scenario: See login form
    When I go to the login page
    Then I should see the visitors header
      And I should see "Sign in" within ".sign_in_form"
      And I should see the common footer

  Scenario: Login with invalid data - see flash message not AR errors
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And a reporter exists with username: "Frank", organization: the organization
    When I go to the login page
     And I fill in "Username or Email" with "not a real user"
     And I fill in "Password" with ""
     And I press "Sign in"
    Then I should see "Wrong Username/email and password combination"
     And I should not see "There were problems with the following fields:"

  Scenario: Login as a reporter with a username
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And a reporter exists with username: "Frank", organization: the organization
      And I go to the login page
      And I fill in "Email" with "Frank"
      And I fill in "Password" with "password"
    When I press "Sign in"
    Then I should see the reporters admin nav
      And I should see the main nav tabs

  Scenario: Login as a reporter with email address
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
    When I go to the login page
      And I fill in "Username or Email" with "reporter@hrtapp.com"
      And I fill in "Password" with "password"
      And I press "Sign in"
    Then I should see the reporters admin nav
      And I should see "reporter@hrtapp.com"
      And I should be on the reporter dashboard page
