Feature: Activity Manager can see dashboard
  In order to
  As an Activity Manager
  I want to be able to see a dashboard for relevant activities

Scenario: "See data requests"
  Given an organization exists with name: "Test Org"
  And an activity_manager exists with username: "Frank", organization: the organization
  And I am signed in as "Frank"
  When I go to the reporter dashboard page
  Then I should see "Data Requests"
  Then show me the page

@wip
Scenario: See Projects/Implementers/etc tabs when a Data Req is selected
  Given an organization exists with name: "WHO"
  And a data_request exists with title: "Some request", organization: the organization

  And an organization exists with name: "UNAIDS"
  And an activity_manager exists with username: "some_user", organization: the organization
  And I am signed in as "some_user"
  And I go to the reporter dashboard page
  When I press "Respond"
  Then I should see the data response tabs
