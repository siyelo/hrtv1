Feature: Reporter can reset password
  In order to change the password I forgot
  As a reporter
  I want to be able to reset password

  Background:
    Given an organization exists with name: "MoH"
      And a data_request exists with organization: the organization
      And an organization exists with name: "Some Donor"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization


  Scenario: Reporter can reset password
    Given I go to the home page
      And I fill in "Email" with "reporter@hrtapp.com" within "#new_password_reset"
      And I press "Send" within "#new_password_reset"
    Then "reporter@hrtapp.com" should receive an email

    When I open the email with subject "\[Health Resource Tracker\] Password Reset Instructions"
      And I follow "password_resets" in the email
      And I fill in "New Password" with "password2"
      And I fill in "Password confirmation" with "password2"
      And I press "Change My Password"
    Then I should see the reporters admin nav
    When I follow "Sign Out"
      And I fill in "Email" with "reporter@hrtapp.com"
      And I fill in "Password" with "password2"
      And I press "Sign in"
    Then I should see the reporters admin nav
