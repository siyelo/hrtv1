Feature: Reporter can see dashboard
  In order to see latest news
  As a reporter
  I want to be able to see a dashboard for relevant activities

Scenario: "See data requests"
  Given I am signed in as a reporter
  When I go to the reporter dashboard page
  Then I should see "Dashboard"

@wip
Scenario: See Projects/Implementers/etc tabs when a Data Req is selected
  Given a basic org + reporter profile, with data response, signed in
  When I go to the reporter dashboard page
  And I press "Respond"
  Then I should see the data response tabs

@reporter_dashboard
Scenario: See unfulfilled/current Data Requests listed
  Given an organization exists with name: "WHO"
  And a data_request exists with title: "Req2", organization: the organization
  And a data_request exists with title: "Req1", organization: the organization
  And an organization exists with name: "UNAIDS"
  And a reporter exists with username: "some_user", organization: the organization
  And a data_response exists with data_request: the data_request, organization: the organization
  And I am signed in as "some_user"
  When I go to the reporter dashboard page
  Then I should see "Req1" within ".current_request"
  And I should see "Req2" within ".admin_dashboard li"

@reporter_dashboard
Scenario: Bug: should not see Projects/Implementers/etc tabs until a Data Req is selected
  Given I am signed in as a reporter
  When I go to the reporter dashboard page
  Then I should not see the data response tabs
