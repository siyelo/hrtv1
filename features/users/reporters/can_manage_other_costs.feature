@run
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
  When I follow "Other Costs"

Scenario: Reporter can CRUD other costs
  When I follow "Create Other Cost"
  And I fill in "Description" with "OtherCost1 description"
  And I check "project1"
  And I press "Create Other Cost"
  Then I should see "Other Cost was successfully created"
  And I should see "OtherCost1 description"

  When I follow "Edit"
  And I fill in "Description" with "OtherCost2 description"
  And I press "Update Other Cost"
  Then I should see "Other Cost was successfully updated"
  And I should see "OtherCost2 description"
  And I should not see "OtherCost1"

  When I follow "X"
  Then I should see "Other Cost was successfully destroyed"
  And I should not see "OtherCost1"
  And I should not see "OtherCost2"

Scenario Outline: Reporter can create an other costs at an Org level (i.e. without a project)
  When I follow "Create Other"
  And I fill in "Description" with "<description>"
  And I check "<project>"
  And I press "Create Other Cost"
  Then I should not see "Oops, we couldn't save your changes."

  Examples:
      | description | project | 
      | d1          |         |

Scenario: Reporter can upload other costs
  When I attach the file "spec/fixtures/other_costs.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Created 4 of 4 other costs successfully"
  And I should see "oc1 description"
  And I should see "oc2 description"
  And I should see "oc3 description"
  And I should see "oc4 description"

Scenario: Reporter can see error if no csv file is not attached for upload
  When I press "Upload and Import"
  Then I should see "Please select a file to upload"

Scenario: Reporter can see error when invalid csv file is attached for upload and download template
  When I attach the file "spec/fixtures/invalid.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Wrong fields mapping. Please download the CSV template"
  When I follow "Download template"
  Then I should see "project_name,description,budget,spend,spend_q4_prev,spend_q1,spend_q2,spend_q3,spend_q4"

Scenario: A reporter can create comments for an other cost
  Given an other_cost exists with project: the project, description: "OtherCost1 description", data_response: the data_response
  When I follow "Other Costs"
  And I follow "OtherCost1 description"
  And I fill in "Title" with "Comment title"
  And I fill in "Comment" with "Comment body"
  And I press "Create Comment"
  Then I should see "Comment title"
  And I should see "Comment body"
  And I should see "OtherCost1 description"

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
