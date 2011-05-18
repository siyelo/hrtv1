Feature: Reporter can see workplan
  In order to review all my entered data
  As a reporter
  I want to be able to see my workplan

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And a data_response exists with data_request: the data_request, organization: the organization
      And a project exists with name: "project1", data_response: the data_response
      And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
      And an activity exists with name: "activity1", description: "activity1 description", data_response: the data_response, project: the project, budget: 100, spend: 200
      And I am signed in as "reporter"

    Scenario: Reporter can manage workplan
      When I follow "Projects"
        And I follow "Manage"
      Then I should see "Manage" within "h1"
        And I should see "project1"
        And I should see "activity1 description"
      When I follow "Delete activity"
      Then I should see "project1"
        And I should not see "activity1 description"
      When I follow "Delete project"
      Then I should not see "project1"
        And I should not see "activity1 description"
