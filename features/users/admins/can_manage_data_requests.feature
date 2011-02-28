Feature: Admin can manage data requests
  In order to collect data in the system
  As a admin
  I want to be able to manage data requests

  @run
Scenario: Admin can CRUD data requests
  Given an organization exists with name: "Organization1"
  And an organization exists with name: "Organization2"
  And an admin exists with username: "admin", organization: the organization
  And I am signed in as "admin"
  When I follow "Data requests"
  And I follow "New"
  And I select "Organization1" from "Organization"
  And I fill in "Title" with "My data response title"
  And I press "Create data request"
  Then I should see "Data request was successfully created."
  And I should see "My data response title"
  And I should see "Organization1"
  When I follow "Edit"
  And I fill in "Title" with "My new data response title"
  And I press "Update data request"
  Then I should see "Data request was successfully updated."
  And I should see "My new data response title"
  When I follow "Delete"
  Then I should see "Data request was successfully deleted."
