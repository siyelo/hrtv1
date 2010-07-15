Feature: Reporter can login
  In order to protect information
  As a reporter
  I want to be able to login

Scenario: Login with invalid data - see flash message not AR errors
  Given a reporter "Frank" with email "frank@f.com" and password "password"
  When I go to the login page
  And I fill in "Username or email" with "not a real user"
  And I fill in "Password" with ""
  And I press "Submit"
  Then I should see "Wrong Username/email and password combination"
  And I should not see "There were problems with the following fields:"

@run
Scenario: Login as a reporter with a username
  Given a reporter "Frank" with email "frank@f.com" and password "password"
  When I go to the login page
  Then I should see "Username or email"
  When I fill in "Username or email" with "Frank"
  And I fill in "Password" with "password"
  And I press "Submit"
  Then show me the page
  Then I should be on the ngo dashboard page
  And I should see "Welcome Frank"
  And I should see "Dashboard"
  And I should see "My Profile"
  

Scenario: Login as a reporter with email address
  Given a reporter "Frank" with email "frank@f.com" and password "password"
  When I go to the login page
  Then I should see "Username or email"
  When I fill in "Username or email" with "frank@f.com"
  And I fill in "Password" with "password"
  And I press "Submit"
  Then I should be on the ngo dashboard page
  And I should see "Welcome Frank"

  
