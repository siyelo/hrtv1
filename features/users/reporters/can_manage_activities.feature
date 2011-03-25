Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

Background:
  Given an organization exists with name: "organization1"
  And a data_request exists with title: "data_request1"
  And an organization "my_organization" exists with name: "organization2"
  And a data_response exists with data_request: the data_request, organization: organization "my_organization"
  And a reporter exists with username: "reporter", organization: organization "my_organization"
  And a project exists with name: "project1", data_response: the data_response
  And a location exists with short_display: "Location1"
  And the location is one of the project's locations
  And a location exists with short_display: "Location2"
  And the location is one of the project's locations
  And I am signed in as "reporter"
  And I follow "data_request1"
  And I follow "Activities"

@javascript
Scenario: Reporter can CRUD activities
  When I follow "Create Activity"
  And I fill in "Name" with "Activity1"
  And I fill in "Description" with "Activity1 description"
  And I fill in "Start date" with "2011-01-01"
  And I fill in "End date" with "2011-12-01"
  And I select "project1" from "Project"
  And I check "Location1"
  And I check "Location2"
  And I press "Create New Activity"
  Then I should see "Activity was successfully created"
  And I should see "Activity1 description"
  And I should see "Location1, Location2"

  When I follow "Edit"
  And I fill in "Name" with "Activity2"
  And I fill in "Description" with "Activity2 description"
  And I uncheck "Location2"
  And I press "Update Activity"
  Then I should see "Activity was successfully updated"
  And I should see "Activity2 description"
  And I should not see "Activity1"
  And I should see "Location1"
  And I should not see "Location2"

  When I confirm the popup dialog
  And I follow "X"
  Then I should see "Activity was successfully destroyed"
  And I should not see "Activity1"
  And I should not see "Activity2"

Scenario Outline: Reporter can CRUD activities and see errors
  When I follow "Create Activity"
  And I fill in "Name" with "<name>"
  And I fill in "Start date" with "<start_date>"
  And I fill in "End date" with "<end_date>"
  And I select "<project>" from "Project"
  And I press "Create New Activity"
  Then I should see "Oops, we couldn't save your changes."
  And I should see "<message>"

  Examples:
     | name | start_date | end_date   | project  | message                       |
     #|      | 2011-01-01 | 2011-12-01 | project1 | Name can't be blank           |
     #| a1   |            | 2011-12-01 | project1 | Start date is an invalid date |
     #| a1   | 2011-01-01 |            | project1 | End date is an invalid date   |
     | a1   | 2011-01-01 | 2011-12-01 |          | Project can't be blank        |

Scenario: Reporter can enter 3 year budget projections
  When I follow "Create Activity"
  And I fill in "Name" with "Activity1"
  And I fill in "Description" with "Activity1 description"
  And I fill in "Start date" with "2011-01-01"
  And I fill in "End date" with "2011-12-01"
  And I select "project1" from "Project"
  And I fill in "Budget" with "1000"
  And I fill in "Budget for year + 1" with "2000"
  And I fill in "Budget for year + 2" with "3000"
  And I press "Create New Activity"
  Then I should see "Activity was successfully created"
  And I should see "Activity1 description"
  When I follow "Edit"
  Then the "Budget" field should contain "1000"
  And the "Budget for year + 1" field should contain "2000"
  And the "Budget for year + 2" field should contain "3000"

Scenario: Reporter can upload activities
  When I attach the file "spec/fixtures/activities.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Created 4 of 4 activities successfully"
  And I should see "a1 description"
  And I should see "a2 description"
  And I should see "a3 description"
  And I should see "a4 description"

Scenario: Reporter can see error if no csv file is not attached for upload
  When I press "Upload and Import"
  Then I should see "Please select a file to upload"

Scenario: Reporter can see error when invalid csv file is attached for upload and download template
  When I attach the file "spec/fixtures/invalid.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Wrong fields mapping. Please download the CSV template"
  When I follow "Download template"
  Then I should see "project_name,name,description,start_date,end_date,text_for_targets,text_for_beneficiaries,text_for_provider,spend,spend_q4_prev,spend_q1,spend_q2,spend_q3,spend_q4,budget,budget2,budget3,budget_q4_prev,budget_q1,budget_q2,budget_q3,budget_q4"

Scenario: A reporter can create comments for an activity
  Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
  When I follow "Activities"
  And I follow "Activity1 description"
  And I fill in "Title" with "Comment title"
  And I fill in "Comment" with "Comment body"
  And I press "Create Comment"
  Then I should see "Comment title"
  And I should see "Comment body"
  And I should see "Activity1 description"

Scenario: A reporter can create comments for an activity and see comment errors
  Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
  When I follow "Activities"
  And I follow "Activity1 description"
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
  And I should see "Activity1 description"
  
Scenario: Does not email users when a comment is made by a reporter
  Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
  And no emails have been sent
  And I follow "Activities"
  And I follow "Activity1 description"
  When I fill in "Comment" with "Comment body"  
  And I fill in "Title" with "Comment title"
  And I fill in "Comment" with "Comment body"
  And I press "Create Comment"
  And "reporter_1@example.com" should not receive an email
  

Scenario: A reporter can select implementer for an activity
  When I follow "Create Activity"
  # check if by default reporter organization is selected
  Then the "Implementer" field should contain "organization2"
  When I fill in "Name" with "Activity1"
  And I fill in "Description" with "Activity1 description"
  And I select "organization1" from "Implementer"
  And I select "project1" from "Project"
  And I press "Create New Activity"
  Then I should see "Activity was successfully created"
  And I should see "Activity1 description"
  And I should see "organization1"

Scenario: A reporter can filter activities
  Given an activity exists with name: "activity2", description: "activity1 description", project: the project, data_response: the data_response
  And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response
  When I follow "Activities"
  Then I should see "activity1 description"
  And I should see "activity2 description"
  And I fill in "query" with "activity1"
  And I press "Search"
  Then I should see "activity1 description"
  And I should not see "activity2 description"

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

@javascript
Scenario: A reporter can create funding sources for an activity
  Given an organization "funding_organization1" exists with name: "funding_organization1"
  And a funding_flow exists with from: organization "funding_organization1", to: organization "my_organization", project: the project, data_response: the data_response
  And an organization "funding_organization2" exists with name: "funding_organization2"
  And a funding_flow exists with from: organization "funding_organization2", to: organization "my_organization", project: the project, data_response: the data_response

  When I follow "Create Activity"
  And I fill in "Name" with "Activity1"
  And I fill in "Description" with "Activity1 description"
  And I select "project1" from "Project"
  And I follow "Add funding source"
  And I select "funding_organization1" from "Organization" within ".fields"
  And I fill in "Spent" with "111" within ".fields"
  And I fill in "Budget" with "222" within ".fields"
  And I press "Create New Activity"
  Then I should see "Activity was successfully created"
  And I should see "Activity1 description"
  And I should see "Activity1 description"
  And I should see "funding_organization1"
  And I should not see "funding_organization2"
  And I should see "111.0 RWF"
  And I should see "222.0 RWF"

  When I follow "Edit"
  And I select "funding_organization2" from "Organization" within ".fields"
  And I fill in "Spent" with "333" within ".fields"
  And I fill in "Budget" with "444" within ".fields"
  And I press "Update Activity"
  Then I should see "Activity was successfully updated"
  And I should see "funding_organization2"
  And I should not see "funding_organization1"
  And I should see "333.0 RWF"
  And I should see "444.0 RWF"
