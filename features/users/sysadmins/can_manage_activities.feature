Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And an sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
      And an organization exists with name: "organization2"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "project2", data_response: the data_response
      And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response
      And an implementer_split exists with budget: "2", spend: "2", organization: the organization, activity: the activity
      And I am signed in as "sysadmin@hrtapp.com"

    Scenario: An admin can review activities
      When I follow "Organizations"
        And I follow "organization2"
        And I follow "activity2"
      Then the "Name" field should contain "activity2"
        And the "Description" field should contain "activity2 description"
      When I follow "Delete this Activity"
      Then I should see "Activity was successfully destroyed"

    Scenario: An admin can edit activity
      When I follow "Organizations"
        And I follow "organization2"
        And I follow "activity2"
        And I fill in "Name" with "activity2 edited"
        And I fill in "Description" with "activity2 description edited"
        And I press "Save"
      Then the "Name" field should contain "activity2 edited"
        And the "Description" field should contain "activity2 description edited"

    Scenario: An admin can create comments for an activity
      When I follow "Organizations"
        And I follow "organization2"
        And I follow "activity2"
        And I fill in "Comment" with "Comment body"
        And I press "Create Comment"
      Then I should see "Comment body"
        # confirm being on the activity edit form
        And the "Name" field should contain "activity2"

    @javascript
    Scenario: An admin can approve classified activity
      Given an activity exists with name: "activity1", description: "a1 description", data_response: the data_response, project: the project, coding_budget_valid: true, coding_budget_cc_valid: true, coding_budget_district_valid: true, coding_spend_valid: true, coding_spend_cc_valid: true, coding_spend_district_valid: true
      When I follow "Organizations"
        And I follow "organization2"
        And I follow "activity1"
        And I follow "Approve (Admin)"
        And wait a few moments
      Then I should see "Admin Approved"

    @javascript
    Scenario: An admin cannot approve unclassified activity
      When I follow "Organizations"
        And I follow "organization2"
        And I follow "activity2"
        And I press "Save"
        And I run delayed jobs
        And I follow "Approve (Admin)"
        And wait a few moments
      Then I should not see "Admin Approved"
