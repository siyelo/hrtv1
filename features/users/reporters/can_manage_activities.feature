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
    And I select "organization2" from "activity_implementer_splits_attributes_0_provider_mask"
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I press "Save"
    Then I should see "Activity was successfully updated."
    And the "activity[implementer_splits_attributes][0][spend]" field should contain "99"
    And the "activity[implementer_splits_attributes][0][budget]" field should contain "19"

  Scenario: Reporter can CRUD activities
    When I follow "Add Activities now"
    And I fill in "activity_name" with "activity1"
    And I fill in "activity_description" with "activity1 description"
    And I select "project1" from "Project"
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
    And I press "Save"
    Then I should see "Activity was successfully created. Click here to enter the funding sources for the automatically created project."
    When I fill in "Name" with "activity2"
    And I fill in "Description" with "activity2 description"
    And I select "<Automatically create a project for me>" from "Project"
    And I press "Save"
    Then I should see "Activity was successfully updated. Click here to enter the funding sources for the automatically created project."



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

  #can't test with combobox
  @wip
  Scenario: A reporter can select implementer for an activity
    When I follow "Add Activities now"
    Then I select "organization2" from "Implementer"
    When I fill in "Name" with "Activity1"
    And I fill in "Description" with "Activity1 description"
    And I select "organization1" from "Implementer"
    And I select "project1" from "Project"
    And I fill in "Budget" with "999"
    And I fill in "Expenditure" with "2000"
    And I press "Save & Classify >"
    Then I should see "Activity was successfully created"
    When I follow "Details"
    Then the "Implementer" field should contain "organization1"


  @wip
  Scenario: A reporter can filter activities
    Given an activity exists with name: "activity2", description: "activity1 description", project: the project, data_response: the data_response
      And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response
    When I follow "Activities"
    Then I should see "activity1 description"
      And I should see "activity2 description"

    When I fill in "query" with "activity1"
      And I press "Search"
    Then I should see "activity1 description"
    And I should not see "activity2 description"


  @wip
  Scenario Outline: A reporter can sort activities
    Given an activity exists with name: "activity1", description: "activity1 description", project: the project, data_response: the data_response, spend: 1, budget: 1
    And a project exists with name: "project2", data_response: the data_response
    And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response, spend: 2, budget: 2
    When I follow "Activities"
    And I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text1>"
    And column "<column>" row "2" should have text "<text2>"
    When I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text2>"
    And column "<column>" row "2" should have text "<text1>"

    Examples:
        | column_name  | column | text1                 | text2                 |
        | Project      | 1      | project1              | project2              |
        | Description  | 2      | activity1 description | activity2 description |
        | Total Spent  | 3      | 1.0 RWF               | 2.0 RWF               |
        | Total Budget | 4      | 1.0 RWF               | 2.0 RWF               |


  #combobox
  @javascript @wip
  Scenario: A reporter can create funding sources for an activity
    Given an organization "funding_organization1" exists with name: "funding_organization1"
    And a funding_flow exists with from: organization "funding_organization1", to: organization "my_organization", project: the project, data_response: the data_response
    And an organization "funding_organization2" exists with name: "funding_organization2"
    And a funding_flow exists with from: organization "funding_organization2", to: organization "my_organization", project: the project, data_response: the data_response
    When I follow "Add Activities now"
    And I fill in "Name" with "Activity1"
    And I fill in "Description" with "Activity1 description"
    And I select "project1" from "Project"
    And I follow "Add funding source"
    And I select "funding_organization1" from "Organization" within ".fields"
    And I fill in "Expenditure" with "111" within ".fields"
    And I fill in "Budget" with "222" within ".fields"
    And I press "Save & Classify >"
    Then I should see "Activity was successfully created"
    And I follow "Projects"
    When I follow "Activity1 description"
    And I follow "Edit" within ".fields"
    And I select "funding_organization2" from "Organization" within ".fields"
    And I fill in "Expenditure" with "333" within ".fields"
    And I fill in "Budget" with "444" within ".fields"
    And I press "Save & Classify >"
    Then I should see "Activity was successfully updated"

  Scenario: Reporter can export Implementers
    Given an activity exists with description: "activity1", project: the project, data_response: the data_response
    And an organization exists with name: "implementer"
    And a sub_activity exists with activity: the activity, provider: the organization, spend: 111, budget: 222, data_response: the data_response
    When I follow "Projects"
    And I follow "activity1"
    And I follow "Export" within "#sub_activities_upload_box"
    Then I should see "Implementer,Past Expenditure,Current Budget"
    And I should see "implementer,111.0,222.0"


  Scenario: Reporter can see message when attached malformed CSV file for implementers
    Given an activity exists with description: "activity1", project: the project, data_response: the data_response
    When I follow "Projects"
    And I follow "activity1"
    And I attach the file "spec/fixtures/malformed.csv" to "File" within "#sub_activities_upload_box"
    And I press "Import" within "#sub_activities_upload_box"
    Then I should see "Your CSV file does not seem to be properly formatted."

  Scenario: Reporter can see message when no file attached for implementers
    Given an activity exists with description: "activity1", project: the project, data_response: the data_response
    When I follow "Projects"
    And I follow "activity1"
    And I press "Import" within "#sub_activities_upload_box"
    Then I should see "Please select a file to upload implementers."

#wip till implementers upload rewrite
  @wip
  Scenario: Reporter can upload and change implementers
    Given an activity exists with description: "activity1", project: the project, data_response: the data_response
    When I follow "Projects"
    And I follow "activity1"
    And I attach the file "spec/fixtures/implementers.csv" to "File" within "#sub_activities_upload_box"
    And I press "Import" within "#sub_activities_upload_box"
    Then I should see "Implementers were successfully uploaded."
    And the "Implementer Past Expenditure" field should contain "66"
    And the "Implementer Current Budget" field should contain "77"

  @wip
  Scenario: Reporter can upload and change implementers
    Given an activity exists with description: "activity1", project: the project, data_response: the data_response
    And sub_activity exists with budget: 66, spend: 77, data_response: the data_response, activity: the activity, provider: the organization, id: 100
    When I follow "Projects"
    And I follow "activity1"
    And I attach the file "spec/fixtures/implementers_update.csv" to "File" within "#sub_activities_upload_box"
    And I press "Import" within "#sub_activities_upload_box"
    Then I should see "Implementers were successfully uploaded."
    And the "Implementer Past Expenditure" field should contain "99"
    And the "Implementer Current Budget" field should contain "100"
