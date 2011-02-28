Feature: Admin can manage data requests
  In order to collect data in the system
  As a admin
  I want to be able to manage data requests

  @wip
Scenario: Admin can CRUD data requests
  Given an organization exists with name: "Organization"
  And an admin exists with name "Admin" with organization: the organization
  And I am signed in as "Admin"
  When I follow "Data requests"
  And I follow "New"
  And I fill in "Title" with "My data response title"
  And I press "Create data request"
  Then I should see "Data request has been successfully created."
  And I should see "My data response title"
  When I follow "Edit"
  And I fill in "Title" with "My new data response title"
  And I press "Update data response"
  Then I should see "Data request has been successfully updated."
  And I should see "My new data response title"
  When I follow "Delete"
  Then I should see "Data request has been successfully deleted."



