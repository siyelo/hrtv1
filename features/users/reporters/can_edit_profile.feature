Feature: Reporter can edit profile
  In order to change my details
  As a reporter
  I want to be able to change my profile

  Background:
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a data_response should exist with data_request: the data_request, organization: the organization
    And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
    And I am signed in as "reporter@hrtapp.com"

  Scenario: User can change credentials and login again
    Given I follow "My Profile"
      And I fill in "New password" with "password2"
      And I fill in "Confirm new password" with "password2"
    When I press "Save"
    Then I should see "Profile was successfully updated"
    When I follow "Sign Out"
    Then I should see "Successfully signed out. "
    When I follow "Sign in"
    And I fill in "Email" with "reporter@hrtapp.com"
    And I fill in "Password" with "password2"
    And I press "Sign in"
    Then I should see "Sign Out"

  Scenario: User can change name and email and login again without changing the password
    And I follow "My Profile"
    And I fill in "Email" with "frank@example.com"
    And I press "Save"
    Then I should see "Profile was successfully updated"
    When I follow "Sign Out"
    Then I should see "Successfully signed out. "
    When I follow "Sign in"
    And I fill in "Email" with "frank@example.com"
    And I fill in "Password" with "password"
    And I press "Sign in"
