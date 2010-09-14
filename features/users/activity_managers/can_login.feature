Feature: Activity Manager can login
  In order to protect information
  As an Activity Manager
  I want to be able to login
  
Scenario: Login as an activity manager with a username
  Given an activity manager "Frank" with email "frank@f.com" and password "password"
  When I go to the login page
  When I fill in "Username or Email" with "Frank"
  And I fill in "Password" with "password"
  And I press "Sign in"
  And I should see the reporters admin nav
  And I should see the main nav tabs
