Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

  Background:
    Given an organization exists with name: "organization1"
    And a data_request exists with title: "data_request1"
    And an organization "my_organization" exists with name: "organization2"
    Then data_response should exist with data_request: the data_request, organization: the organization
    And a reporter exists with email: "reporter@hrtapp.com", organization: organization "my_organization"
    And a project exists with name: "project1", data_response: the data_response
    And I am signed in as "reporter@hrtapp.com"
    And I go to the set request page for "data_request1"
    And I follow "Projects"

  Scenario: Reporter can CRUD activities
    When I follow "Add Activities now"
    And I fill in "activity_name" with "activity1"
    And I fill in "activity_description" with "activity1 description"
    And I select "project1" from "Project"
    # self org should already be present/selected
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I press "Save"
    Then I should see "Activity was successfully created"
    And I fill in "Name" with "activity2"
    And I fill in "Description" with "activity2 description"
    And I press "Save"
    Then I should see "Activity was successfully updated"
    And I follow "Projects"
    When I follow "activity2"
    And I follow "Delete this Activity"
    Then I should see "Activity was successfully destroyed"

  Scenario: Reported can create activity with automatically created project
    When I follow "Add Activities now"
    And I fill in "activity_name" with "activity1"
    And I fill in "activity_description" with "activity1 description"
    And I select "<Automatically create a project for me>" from "Project"
    # self org should already be selected
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I press "Save"
    Then I should see "Activity was successfully created. Click here to enter the funding sources for the automatically created project."
    When I fill in "Name" with "activity2"
    And I fill in "Description" with "activity2 description"
    And I select "<Automatically create a project for me>" from "Project"
    And I press "Save"
    Then I should see "Activity was successfully updated. Click here to enter the funding sources for the automatically created project."

  @javascript
  Scenario: Reporter can add targets & outputs
    Given an activity exists with project: the project, name: "existing activity", description: "existing description", data_response: the data_response
    When I follow "Projects"
    And I follow "existing activity"
    And I follow "Targets, Outputs & Beneficiaries"
    And I follow "Add Target"
    And I fill in "target_field" with "Target description"
    And I follow "Add Output"
    And I fill in "output_field" with "Output description"
    And I press "Save"
    Then I should see "Activity was successfully updated"
    And the "target_field" field should contain "Target description"
    And the "output_field" field should contain "Output description"

  Scenario: Reporter can add implementers with percentages
    Given an activity exists with project: the project, name: "existing activity", description: "existing description", data_response: the data_response
    When I follow "Projects"
    And I follow "existing activity"
    And I follow "Implementers" within ".section_nav"
    And I select "organization2" from "activity_implementer_splits_attributes_0_organization_mask"
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I press "Save"
    Then I should see "Activity was successfully updated."
    And the "activity[implementer_splits_attributes][0][spend]" field should contain "99"
    And the "activity[implementer_splits_attributes][0][budget]" field should contain "19"

  Scenario: Reporter can see error message when adding duplicate implementers to new activity
    When I follow "Add Activities now"
    And I fill in "activity_name" with "activity1"
    And I fill in "activity_description" with "activity1 description"
    And I select "project1" from "Project"
    # self org should already be present/selected
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I select "organization2" from "activity_implementer_splits_attributes_1_organization_mask"
    And I fill in "activity[implementer_splits_attributes][1][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][1][budget]" with "19"
    And I press "Save"
    Then I should see "Duplicate Implementer"

  Scenario: Reporter can see error message when adding duplicate implementers to existing activity
    Given an activity exists with project: the project, name: "existing activity", description: "existing description", data_response: the data_response
    When I follow "Projects"
    And I follow "existing activity"
    And I follow "Implementers" within ".section_nav"
    And I select "organization2" from "activity_implementer_splits_attributes_0_organization_mask"
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I select "organization2" from "activity_implementer_splits_attributes_1_organization_mask"
    And I fill in "activity[implementer_splits_attributes][1][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][1][budget]" with "19"
    And I press "Save"
    Then I should see "Duplicate Implementer"

  @javascript
  Scenario: Reporter can see live total being updated
    Given an activity exists with project: the project, name: "existing activity", description: "existing description", data_response: the data_response
    When I follow "Projects"
    And I follow "existing activity"
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][1][spend]" with "100"
    Then I should see "199"

  Scenario: A reporter can create comments for a Activity
    Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
    When I follow "Projects"
    And I follow "Activity1 description"
    And I press "Create Comment"
    Then I should see "You cannot create blank comment."
    When I fill in "Comment" with "Comment body"
    And I press "Create Comment"
    Then I should see "Comment body"

  Scenario: Does not email users when a comment is made by a reporter
    Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
    And no emails have been sent
    When I follow "Projects"
    And I follow "Activity1 description"
    And I fill in "comment_comment" with "Comment body"
    And I press "Create Comment"
    Then "reporter_1@example.com" should not receive an email
