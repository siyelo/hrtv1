Feature: Reporter can manage projects
  In order to track information
  As a reporter
  I want to be able to manage my projects

Background:
  Given an organization exists with name: "organization1"
  And a data_request exists with title: "data_request1"
  And an organization exists with name: "organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization
  And a location exists with short_display: "Location1"
  And a location exists with short_display: "Location2"
  And I am signed in as "reporter"
  And I follow "data_request1"
  When I follow "Projects"

Scenario: Reporter can CRUD projects
  When I follow "Create Project"
  And I fill in "Name" with "Project1"
  And I fill in "Description" with "Project1 description"
  And I fill in "Start date" with "2011-01-01"
  And I fill in "End date" with "2011-12-01"
  And I check "Location1"
  And I check "Location2"
  And I press "Create New Project"
  Then I should see "Project was successfully created"
  And I should see "Project1"
  And I should see "Location1, Location2"

  When I follow "Edit"
  And I fill in "Name" with "Project2"
  And I fill in "Description" with "Project2 description"
  And I uncheck "Location1"
  And I press "Update Project"
  Then I should see "Project was successfully updated"
  And I should see "Project2"
  And I should not see "Project1"
  And I should see "Location2"
  And I should not see "Location1"

  When I follow "X"
  Then I should see "Project was successfully destroyed"
  And I should not see "Project1"
  And I should not see "Project2"

Scenario Outline: Edit project dates, see feedback messages for start and end dates
  When I follow "Create Project"
  And I fill in "Name" with "Some Project"
  And I fill in "Start date" with "<start_date>"
  And I fill in "End date" with "<end_date>"
  And I press "Create"
  Then I should see "<message>"
  And I should see "<specific_message>"

  Examples:
    | start_date | end_date   | message                              | specific_message                      |
    | 2010-01-01 | 2010-01-02 | Project was successfully created     | Project was successfully created      |
    |            | 2010-01-02 | Oops, we couldn't save your changes. | Start date is an invalid date         |
    | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date. |

Scenario Outline: Edit project dates, see feedback messages for Total budget and Total budget GOR
  When I follow "Create Project"
  And I fill in "Name" with "Some Project"
  And I fill in "Start date" with "<start_date>"
  And I fill in "End date" with "<end_date>"
  And I fill in "Lifetime budget" with "<entire_budget>"
  And I fill in "Budget" with "<budget_gor>"
  And I press "Create"
  Then I should see "<message>"
  And I should see "<specific_message>"

  Examples:
    | start_date | end_date   | entire_budget | budget_gor | message                              | specific_message                                                     |
    | 2010-01-01 | 2010-01-02 | 900           | 800        | Project was successfully created     | Project was successfully created                                     |
    | 2010-01-01 | 2010-01-02 | 900           | 900        | Project was successfully created     | Project was successfully created                                     |
    | 2010-05-05 | 2010-01-02 | 900           | 1000       | Oops, we couldn't save your changes. | Total Budget must be less than or equal to Total Budget GOR FY 10-11 |

Scenario: Reporter can upload projects
  When I attach the file "spec/fixtures/projects.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Created 4 of 4 projects successfully"
  And I should see "p1"
  And I should see "p2"
  And I should see "p3"
  And I should see "p4"

Scenario: Reporter can see error if no csv file is not attached for upload
  When I press "Upload and Import"
  Then I should see "Please select a file to upload"

Scenario: Reporter can see error when invalid csv file is attached for upload and download template
  When I attach the file "spec/fixtures/invalid.csv" to "File"
  And I press "Upload and Import"
  Then I should see "Wrong fields mapping. Please download the CSV template"
  When I follow "Download template"
  Then I should see "name,description,currency,entire_budget,budget,budget_q4_prev,budget_q1,budget_q2,budget_q3,budget_q4,spend,spend_q4_prev,spend_q1,spend_q2,spend_q3,spend_q4,start_date,end_date"

Scenario: A reporter can create comments for a project
  Given a project exists with name: "project1", data_response: the data_response
  When I follow "Projects"
  And I follow "project1"
  And I fill in "Title" with "Comment title"
  And I fill in "Comment" with "Comment body"
  And I press "Create Comment"
  Then I should see "Comment title"
  And I should see "Comment body"
  And I should see "project1"

Scenario: A reporter can create comments for an activity and see comment errors
  Given a project exists with name: "project1", data_response: the data_response
  When I follow "Projects"
  And I follow "project1"
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
  And I should see "project1"

@javascript
Scenario: A reporter can create in flows for a project
  When I follow "Create Project"
  And I fill in "Name" with "Project1"
  And I fill in "Description" with "Project1 description"
  And I fill in "Start date" with "2011-01-01"
  And I fill in "End date" with "2011-12-01"
  And I follow "Add funding source"
  And I select "organization1" from "From" within ".fields"
  And I fill in "Budget" with "111" within ".fields"
  And I fill in "Spent" with "222" within ".fields"
  And I fill in "Q4 08-09" with "333" within ".fields"
  And I fill in "Q1 09-10" with "444" within ".fields"
  And I fill in "Q2 09-10" with "555" within ".fields"
  And I fill in "Q3 09-10" with "666" within ".fields"
  And I fill in "Q4 09-10" with "777" within ".fields"
  And I press "Create New Project"
  Then I should see "Project was successfully created"
  And I should see "organization1"
  And I should see "111"
  And I should see "222"
  And I should see "333"
  And I should see "444"
  And I should see "555"
  And I should see "666"
  And I should see "777"
  And I should see "Project1"
  When I follow "Edit"
  And I fill in "Q4 09-10" with "7778" within ".fields"
  And I press "Update Project"
  And I should see "7778"
