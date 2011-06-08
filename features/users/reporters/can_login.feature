Feature: Reporter can login
  In order to protect information
  As a reporter
  I want to be able to login

  Scenario: Login with invalid data - see flash message not AR errors
    Given a reporter exists
    When I go to the login page
     And I fill in "Email" with "not a real user"
     And I fill in "Password" with ""
     And I press "Sign in"
    Then I should see "Wrong email and password combination"
     And I should not see "There were problems with the following fields:"

  Scenario: Login as a reporter with email address
    Given a reporter exists with email: "pink.panter@hrt.com"
      And I go to the login page
      And I fill in "Email" with "pink.panter@hrt.com"
      And I fill in "Password" with "password"
    When I press "Sign in"
    Then I should see the reporters admin nav
      And I should see the main nav tabs
