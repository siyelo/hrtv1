Feature: Reporter can login
  In order to protect information
  As a reporter
  I want to be able to login

@reporter_login
Scenario: Login via home page
  When I go to the home page
  And I follow "Sign in"
  Then I should be on the login page

@reporter_login
Scenario: See login form
  When I go to the login page
  Then I should see the visitors header
  And I should see "Sign in" within "body#login"
  And I should see "Username or Email" within "body#login"
  And I should see "Password" within "body#login"
  And I should see the common footer

@reporter_login
Scenario: Login with invalid data - see flash message not AR errors
  Given a reporter exists
  When I go to the login page
  And I fill in "Username or Email" with "not a real user"
  And I fill in "Password" with ""
  And I press "Sign in"
  Then I should see "Wrong Username/email and password combination"
  And I should not see "There were problems with the following fields:"

@reporter_login
Scenario: Login as a reporter with a username
  Given a reporter exists with username: "Frank"
  And I go to the login page
  And I fill in "Username or Email" with "Frank"
  And I fill in "Password" with "password"
  When I press "Sign in"
  Then I should see the reporters admin nav
  And I should see the main nav tabs

@reporter_login
Scenario: Login as a reporter with email address
  Given a reporter exists with email: "frank@f.com"
  When I go to the login page
  And I fill in "Username or Email" with "frank@f.com"
  And I fill in "Password" with "password"
  And I press "Sign in"
  Then I should see the reporters admin nav
  And I should see "frank@f.com"
