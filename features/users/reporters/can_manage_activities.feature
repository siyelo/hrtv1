Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

Background:
  Given an organization exists with name: "organization1"
  And a data_request exists with title: "data_request1"
  And an organization exists with name: "organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization
  And a project exists with name: "project1", data_response: the data_response
  And I am signed in as "reporter"

@run
Scenario: Reporter can CRUD activities
  When I follow "data_request1"
  And I follow "Activities"
  Then show me the page

