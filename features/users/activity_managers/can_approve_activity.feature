Feature: Activity Manager can approve a code breakdown for each activity
  In order to increase the quality of information reported
  As a NGO/Donor Activity Manager
  I want to be able to approve activity splits

  Background:
    Given an organization "admin_org" exists with name: "admin_org"
      And a data_request exists with title: "dr1", organization: the organization
      And an organization "reporter_org" exists with name: "reporter_org"
      And a reporter exists with organization: the organization
      And data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "project1", data_response: the data_response
      And an activity exists with name: "activity1", description: "a1 description", data_response: the data_response, project: the project
      And an organization "ac_org" exists with name: "ac_org"
      And an activity_manager exists with email: "activity_manager@hrtapp.com", organization: the organization
      And organization "reporter_org" is one of the activity_manager's organizations
      And I am signed in as "activity_manager@hrtapp.com"

    @javascript
    Scenario: Approve an Activity
      Given I follow "reporter_org"
        And I follow "activity1"
      When I follow "Approve this Activity's Budget"
        And wait a few moments
      Then I should see "Budget Approved"
