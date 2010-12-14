Feature: Activity Manager can login
  In order to protect information
  As an Activity Manager
  I want to be able to login

@activity_manager_login
Scenario: Login as an activity manager with a username
  Given an activity_manager exists with username: "Frank"
  And I go to the login page
  And I fill in "Username or Email" with "Frank"
  And I fill in "Password" with "password"
  When I press "Sign in"
  Then I should be on the reporter dashboard page
  And I should see the reporters admin nav
  And I should see the main nav tabs
