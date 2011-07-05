Feature: Activity Manager can approve a code breakdown for each activity
  In order to increase the quality of information reported
  As a NGO/Donor Activity Manager
  I want to be able to approve activity splits

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And an organization exists with name: "organization2"
      And a data_response exists with data_request: the data_request, organization: the organization
      And an activity_manager exists with email: "who_manager@hrtapp.com", organization: the organization, current_data_response: the data_response
      And a project exists with name: "project1", data_response: the data_response
      And an activity exists with name: "activity1", description: "a1 description", data_response: the data_response, project: the project
      And mtef_code exists with short_display: "mtef1"
      And an activity_manager exists with email: "activity_manager@hrtapp.com", organization: the organization, current_data_response: the data_response
      And I am signed in as "activity_manager@hrtapp.com"
      And I follow "data_request1"
      And I follow "Workplan"

    @javascript @wip
    Scenario: Approve an Activity
      Given I follow "a1 description"
        And I follow "Budget"
        And I should see "Approved?"
      When I check "approve_activity"
        And wait a few moments
        And I follow "Budget"
      Then the "approve_activity" checkbox should be checked
