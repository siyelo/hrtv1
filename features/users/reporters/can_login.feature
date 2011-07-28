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
    Given a reporter exists
    When I go to the login page
    And I fill in "Email" with "not a real user"
    And I fill in "Password" with "sadf"
    And I press "Sign in"
    Then I should see "Wrong Email and Password combination. If you think this message is being shown in error after multiple tries, use the form on the contact page (link below) to get help"
    And I should not see "There were problems with the following fields:"

  Scenario: Login as a reporter with email address
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", password: "password", organization: the organization    
    When I go to the login page
      And I fill in "Email" with "reporter@hrtapp.com"
      And I fill in "Password" with "password"
      And I press "Sign in"
      Then I should see the reporters admin nav
      And I should see "reporter@hrtapp.com"
      And I should see "Projects"
