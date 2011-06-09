Feature: Can add member
  In order to increase security
  As an org admin
  I want to be able to invite other users to my organization

  @run
  Scenario: Add a member
    Given I am signed in as a member
    Then show me the page
    When I follow "Manage" within the main nav
    # And I follow "Add/Remove Members"
    # Then I should see "Members" within the title
    # And I should see "Add Member"
    # And I should see a User List
    # When I fill in Email with "bob@siyelo.com"
    # And I fill in Full Name with "bob smith"
    # And I select "member" from Role
    # And I press Add
    # Then I should see "An email invitation has been sent to 'bob smith'"
    # And I should see "bob@siyelo.com" in the User List
    # And I should see "1 pending" in the Invitation column for "bob@siyelo.com"




