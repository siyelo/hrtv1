Feature: Can add member
  In order to increase security
  As an org admin
  I want to be able to invite other users to my organization

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a sysadmin exists with email: "member@hrtapp.com", organization: the organization

  Scenario: Add a member
    And I am signed in as "member@hrtapp.com"
    And I follow "Members"
    Then I should see "Members" within the main heading
    And I select "organization1" from "Organization"
    When I fill in "Full name" with "bob smith"
    And I fill in "Email" with "bob@siyelo.com"
    And I select "Reporter" from "Role"
    And I press "Add"
    Then I should see "An email invitation has been sent to 'bob smith'"
    And I should see "bob@siyelo.com"
    And I should see "1 pending"
    # And I should see "1 pending" in the Invitation column for "bob@siyelo.com"




