Feature: Reporter can manage other costs
  In order to track information
  As a reporter
  I want to be able to manage other costs

Background:
  Given an organization exists with name: "organization1"
  And a data_request exists with title: "data_request1"
  And an organization exists with name: "organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization
  And a project exists with name: "project1", data_response: the data_response
  And I am signed in as "reporter"
  When I follow "data_request1"
  And I follow "Projects"

Scenario: Reporter can CRUD other costs
  When I follow "Add Other Costs now"
  Then I should see "Create Other Cost"
  When I fill in "Description" with "other_cost1"
  And I select "project1" from "Project"
  And I press "Save & Next"
  Then I should see "Other Cost was successfully created"

  When I follow "other_cost1"
  And I fill in "Description" with "other_cost2"
  And I press "Save & Next"
  Then I should see "Other Cost was successfully updated"
  And I should see "other_cost2"
  And I should not see "other_cost1"

  When I follow "other_cost2"
  And I follow "Remove this Other Cost"
  Then I should see "Other Cost was successfully destroyed"
  And I should not see "other_cost1"
  And I should not see "other_cost2"

Scenario: Reporter can create an other costs at an Org level (i.e. without a project)
  When I follow "Add Other Costs now"
  And I fill in "Description" with "other_cost1"
  And I press "Save & Next"
  Then I should see "Other Cost was successfully created"

@wip
Scenario: Adding malformed CSV file doesn't throw exception
  When I attach the file "spec/fixtures/malformed.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Your CSV file does not seem to be properly formatted"

@wip
Scenario: Reporter can upload other costs
  When I attach the file "spec/fixtures/other_costs.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Created 4 of 4 other costs successfully"
  And I should see "oc1 description"
  And I should see "oc2 description"
  And I should see "oc3 description"
  And I should see "oc4 description"

@wip
Scenario: Reporter can see error if no csv file is not attached for upload
  When I press "Upload and Import"
  Then I should see "Please select a file to upload"

@wip
Scenario: Reporter can see error when invalid csv file is attached for upload and download template
  When I attach the file "spec/fixtures/invalid.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Wrong fields mapping. Please download the CSV template"
  When I follow "Download template"
  Then I should see "project_name,description,budget,spend,spend_q4_prev,spend_q1,spend_q2,spend_q3,spend_q4"

@wip
Scenario: A reporter can create comments for an other cost
  Given an other_cost exists with project: the project, description: "other_cost1", data_response: the data_response
  When I follow "Projects"
  And I follow "project1"
  And I follow "other_cost1"
  And I fill in "Title" with "Comment title"
  And I fill in "Comment" with "Comment body"
  And I press "Create Comment"
  Then I should see "Comment title"
  And I should see "Comment body"
  And I should see "OtherCost1 description"

@wip
Scenario: A reporter can create comments for an other cost and see comment errors
  Given an other cost exists with project: the project, description: "OtherCost1 description", data_response: the data_response
  When I follow "Other Costs"
  And I follow "OtherCost1 description"
  And I press "Create Comment"
  Then I should see "can't be blank" within "#comment_title_input"
  And I should see "can't be blank" within "#comment_comment_input"

  When I fill in "Title" with "Comment title"
  And I press "Create Comment"
  Then I should not see "can't be blank" within "#comment_title_input"
  And I should see "can't be blank" within "#comment_comment_input"

  When I fill in "Comment" with "Comment body"
  And I press "Create Comment"
  Then I should see "Comment title"
  And I should see "Comment body"
  And I should see "OtherCost1 description"
