Feature: Reporter can start a data response
  In order to enter data
  As a reporter
  I want to be able to start a data response

@reporters @data_response
Scenario: Reporter can start a data resposne
  Given an organization exists with name: "Organization 1"
  And a data_request exists with title: "Request 1"
  And a reporter exists with username: "reporter", organization: the organization
  And I am signed in as "reporter"
  When I follow "Dashboard"
  And I follow "Respond"
  And I select "Request 1" from "Data Request"
  And I fill in "Start of Fiscal Year" with "2011-01-01"
  And I fill in "End of Fiscal Year" with "2012-02-01"
  And I select "Rwandan Franc (RWF)" from "Default Currency"
  And I press "Begin Response"
  Then I should see "Your response was successfully created."


