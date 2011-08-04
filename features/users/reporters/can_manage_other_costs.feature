Feature: Reporter can manage other costs
  In order to track information
  As a reporter
  I want to be able to manage other costs

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And an organization exists with name: "organization2"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "project1", data_response: the data_response
      And I am signed in as "reporter@hrtapp.com"
      And I follow "data_request1"
      And I follow "Projects"

    @javascript
    Scenario: Reporter can CRUD other costs
      When I follow "Add other cost"
      When I fill in "activity_name" with "other_cost1"
        And I fill in "activity_description" with "other_cost1 description"
        And I press "activity_submit"
      Then wait a few moments
        And I fill in the activities budget field with "33" and spend field with "44" for that activity
        And I press "Save"
      Then I should see "Workplan was successfully saved"
      When I follow "other_cost1 description"
        And I fill in "Name" with "other_cost2"
        And I fill in "Description" with "other_cost2 description"
        And I press "Save"
      Then I should see "Othercost was successfully updated"
        And I should see "other_cost2"
        And I should not see "other_cost1"
      When I follow "other_cost2"
        And I follow "Delete this Other Cost"
        And I confirm the popup dialog
      Then I should see "Other Cost was successfully destroyed"
        And I should not see "other_cost1"
        And I should not see "other_cost2"


  Scenario: A reporter can create comments for an other cost
    Given an other_cost exists with project: the project, description: "other_cost1", data_response: the data_response
    When I follow "Projects"
      And I follow "other_cost1"
      And I fill in "Title" with "Comment title"
      And I fill in "Comment" with "Comment body"
      And I press "Create Comment"
    Then I should see "Comment was successfully created"
      And I should see "Comment title"
      And I should see "Comment body"

  Scenario: A reporter can create comments for an other cost and see comment errors
    Given an other cost exists with project: the project, description: "OtherCost1 description", data_response: the data_response
    When I follow "Projects"
      And I follow "OtherCost1 description"
      And I press "Create Comment"
    Then I should see "You cannot create blank comment"
    
    When I fill in "Comment" with "Comment body"
      And I fill in "Title" with "Comment Title"
      And I press "Create Comment"
    Then I should see "Comment was successfully created"
      And I should see "Comment body"


