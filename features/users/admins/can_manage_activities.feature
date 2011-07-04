Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And an admin exists with username: "admin", organization: the organization

      And an organization exists with name: "organization2"
      And a reporter exists with username: "reporter", organization: the organization
      And data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "project2", data_response: the data_response
      And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response, spend: 2, budget: 2
      And I am signed in as "admin"

    Scenario: An admin can review activities
      When I follow "Organizations"
        And I follow "organization2"
        And I follow "activity2 description"
      Then the "Name" field should contain "activity2"
        And the "Description" field should contain "activity2 description"

      When I follow "Delete this Activity"
      Then I should see "Activity was successfully destroyed"


    Scenario: An admin can edit activity
      When I follow "Organizations"
        And I follow "organization2"
        And I follow "activity2 description"
        And I fill in "Name" with "activity2 edited"
        And I fill in "Description" with "activity2 description edited"
        And I press "Save"
      Then the "Name" field should contain "activity2 edited"
        And the "Description" field should contain "activity2 description edited"


    Scenario: An admin can create comments for an activity
      When I follow "Organizations"
        And I follow "organization2"
        And I follow "activity2 description"
        And I fill in "Comment" with "Comment body"
        And I press "Create Comment"
      Then I should see "Comment body"
        # confirm being on the activity edit form
        And the "Name" field should contain "activity2"
