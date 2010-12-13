Feature: Reporter can see user guide upon login
  In order to train users
  As a reporter
  I want to be able to see user guide after logging in

@run
Scenario: Login and see user guide
  Given a reporter exists with username: "Frank", email: "frank@f.com", password: "password"
  When I go to the login page
  And I fill in "Username or Email" with "Frank"
  And I fill in "Password" with "password"
  And I press "Sign in"
  Then I should be on the user guide page
  And I should see the reporters admin nav
  And I should see the main nav tabs
  And I should not see the data response tabs
  And I should see "Using the Resource Tracking Tool"
  And I should see the common footer
