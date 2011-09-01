Feature: Admin can invite users
  In order to track information
  As an admin
  I want to be able to invite users

  Background:
    Given an organization exists with name: "MoH"
    Given a data_request exists with title: "Req1", organization: the organization
    Given an organization exists with name: "organization1"
    And an admin exists with email: "sysadmin@hrtapp.com", organization: the organization
    And I am signed in as "sysadmin@hrtapp.com"


  Scenario: Admin can invite user and user can register and login
    When I follow "Users"
      And I follow "Create User"
      And I select "organization1" from "Organization"
      And I fill in "Email" with "pink.panter1@hrtapp.com"
      And I fill in "Full name" with "Pink Panter"
      And I select "Reporter" from "Role"
      And I press "Create New User"
    Then I should see "User was successfully created"
      And "pink.panter1@hrtapp.com" should receive an email
      And I should see "organization1"
      And I should see "pink.panter1@hrtapp.com"
      And I should see "Pink Panter"

    When I follow "Sign Out"
      And I open the email with subject "\[Health Resource Tracker\] You have been invited to HRT"
      And I follow "registration" in the email
      And I fill in "Password" with "password"
      And I fill in "Password confirmation" with "password"
      And I press "Save"
    Then I should see the reporters admin nav
    When I follow "Sign Out"
      And I fill in "Email" with "pink.panter1@hrtapp.com"
      And I fill in "Password" with "password"
      And I press "Sign in"
    Then I should see the reporters admin nav
