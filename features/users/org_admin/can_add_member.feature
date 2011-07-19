Feature: Can add member
  In order to increase security
  As an org admin
  I want to be able to invite other users to my organization

  Background:
    Given an organization exists with name: "MoH"
      And a ngo exists with name: "ngo"
      And a data_request exists with organization: the organization, title: "request1"
      And a data_response exists with organization: the ngo, data_request: the data_request
      And a reporter exists with email: "member@hrtapp.com", organization: the ngo

  Scenario: Add a member
    And I am signed in as "member@hrtapp.com"
    Then show me the page
    When I follow "Manage" within the main nav
    And I follow "Members" within the sub nav
    Then I should see "Members" within the main heading
    And I should see "Add Member"
    When I fill in "Full name" with "bob smith"
    And I fill in "Email" with "bob@siyelo.com"
    And I select "Reporter" from "Role"
    And I press "Add"
    Then I should see "An email invitation has been sent to 'bob smith'"
    And I should see "bob@siyelo.com" in the User List
    # And I should see "1 pending" in the Invitation column for "bob@siyelo.com"




