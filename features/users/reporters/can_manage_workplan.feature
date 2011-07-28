Feature: Reporter can see workplan
  In order to review all my entered data
  As a reporter
  I want to be able to see my workplan

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "project1", data_response: the data_response
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And an activity exists with id: "1", name: "activity1", description: "activity1 description", data_response: the data_response, project: the project, budget: 100, spend: 200
      And I am signed in as "reporter@hrtapp.com"

    @wip
    Scenario: Reporter can edit activities
      When I follow "Projects"
        And I follow "Workplan"
      Then I should see "Workplan" within "h1"
      When I fill in "activities_1spend_q4_prev" with "1"
      When I fill in "activities_1spend_q1" with "2"
      When I fill in "activities_1spend_q2" with "3"
      When I fill in "activities_1spend_q3" with "4"
      When I fill in "activities_1spend_q4" with "5"
        And I press "Save"
      Then I should see "Workplan was successfully saved"
        And the "activities_1spend_q4_prev" field should contain "1"
        And the "activities_1spend_q1" field should contain "2"
        And the "activities_1spend_q2" field should contain "3"
        And the "activities_1spend_q3" field should contain "4"
        And the "activities_1spend_q4" field should contain "5"

    @wip
    Scenario: Reporter can manage workplan
      When I follow "Projects"
        And I follow "Manage"
      Then I should see "Manage" within "h1"
        And I should see "project1"
        And I should see "activity1 description"
      When I follow "Delete activity"
      Then I should see "project1"
        And I should not see "activity1 description"
