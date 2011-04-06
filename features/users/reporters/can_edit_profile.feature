Feature: Reporter can edit profile
  In order to change my details
  As a reporter
  I want to be able to change my profile

  Background:



    Scenario: User can change credentials and login again
      Given a reporter exists with username: "Frank"
      When I go to the home page
      And I go to the login page
      And I fill in "Username or Email" with "Frank"
      And I fill in "Password" with "password"
      And I press "Sign in"
      And I follow "My Profile"
      And I fill in "User" with "Frank2"
      And I fill in "Password" with "password2"
      And I fill in "Password confirmation" with "password2"
      And I press "Save"
      Then I should see "Profile was successfully updated"

      When I follow "Sign Out"
      Then I should see "Successfully signed out. "

      When I follow "Sign in"
      And I fill in "Username or Email" with "Frank2"
      And I fill in "Password" with "password2"
      And I press "Sign in"
      Then I should see "Successfully signed in."


    Scenario: User can change name and email and login again without changing the password
      Given a reporter exists with username: "Frank"
      When I go to the home page
      And I go to the login page
      And I fill in "Username or Email" with "Frank"
      And I fill in "Password" with "password"
      And I press "Sign in"
      And I follow "My Profile"
      And I fill in "User" with "Frank2"
      And I fill in "Email" with "frank@example.com"
      And I press "Save"
      Then I should see "Profile was successfully updated"

      When I follow "Sign Out"
      Then I should see "Successfully signed out. "

      When I follow "Sign in"
      And I fill in "Username or Email" with "frank@example.com"
      And I fill in "Password" with "password"
      And I press "Sign in"
      Then I should see "Successfully signed in."
