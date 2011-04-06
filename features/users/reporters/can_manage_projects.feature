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
      And I follow "Projects"



    Scenario: Reporter can CRUD projects
      When I follow "Create Project"
        And I fill in "Name" with "Project1"
        And I fill in "Description" with "Project1 description"
        And I fill in "Start date" with "2011-01-01"
        And I fill in "End date" with "2011-12-01"
        And I check "Location1"
        And I check "Location2"
        And I press "Create Project"
      Then I should see "Project was successfully created"
        And I should see "Project1"
        #And I should see "Location1, Location2"

      When I follow "Project1"
        And I fill in "Name" with "Project2"
        And I fill in "Description" with "Project2 description"
        And I uncheck "Location1"
        And I press "Update Project"
      Then I should see "Project was successfully updated"
        #And I should see "Project2"
        #And I should not see "Project1"
        #And I should see "Location2"
        #And I should not see "Location1"

      When I follow "Project2"
        And I follow "Remove this Project"
      Then I should see "Project was successfully destroyed"
        #And I should not see "Project1"
        #And I should not see "Project2"


    Scenario Outline: Edit project dates, see feedback messages for start and end dates
      When I follow "Create Project"
        And I fill in "Name" with "Some Project"
        And I fill in "Start date" with "<start_date>"
        And I fill in "End date" with "<end_date>"
        And I press "Create Project"
      Then I should see "<message>"
        And I should see "<specific_message>"

        Examples:
          | start_date | end_date   | message                              | specific_message                      |
          | 2010-01-01 | 2010-01-02 | Project was successfully created     | Project was successfully created      |
          |            | 2010-01-02 | Oops, we couldn't save your changes. | Start date is an invalid date         |
          | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date. |


    Scenario Outline: Edit project dates, see feedback messages for Total budget and Total budget
      When I follow "Create Project"
        And I fill in "Name" with "Some Project"
        And I fill in "Start date" with "<start_date>"
        And I fill in "End date" with "<end_date>"
        And I fill in "Spend" with "<entire_budget>"
        And I fill in "Budget" with "<budget_gor>"
        And I press "Create"
      Then I should see "<message>"
        And I should see "<specific_message>"

        Examples:
          | start_date | end_date   | entire_budget | budget_gor | message                              | specific_message                                                     |
          | 2010-01-01 | 2010-01-02 | 900           | 800        | Project was successfully created     | Project was successfully created                                     |
          | 2010-01-01 | 2010-01-02 | 900           | 900        | Project was successfully created     | Project was successfully created                                     |

      
    Scenario: Adding malformed CSV file doesn't throw exception
      When I attach the file "spec/fixtures/malformed.csv" to "File"
        And I press "Upload and Import"
      Then I should see "Your CSV file does not seem to be properly formatted."


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


    @javascript
    Scenario: A reporter can create in flows for a project
      When I follow "Create Project"
        And I fill in "Name" with "Project1"
        And I fill in "Description" with "Project1 description"
        And I fill in "Start date" with "2011-01-01"
        And I fill in "End date" with "2011-12-01"
        And I follow "Add funding source"
        And I select "organization1" from "From" within ".fields"
        And I fill in "Spent" with "11" within ".fields"
        And I fill in "Q4 08-09" with "22" within ".fields .spend"
        And I fill in "Q1 09-10" with "33" within ".fields .spend"
        And I fill in "Q2 09-10" with "44" within ".fields .spend"
        And I fill in "Q3 09-10" with "55" within ".fields .spend"
        And I fill in "Q4 09-10" with "66" within ".fields .spend"
        And I fill in "Budget" with "11" within ".fields"
        And I fill in "Q4 08-09" with "22" within ".fields .budget"
        And I fill in "Q1 09-10" with "33" within ".fields .budget"
        And I fill in "Q2 09-10" with "44" within ".fields .budget"
        And I fill in "Q3 09-10" with "55" within ".fields .budget"
        And I fill in "Q4 09-10" with "66" within ".fields .budget"
        And I press "Create Project"
      Then I should see "Project was successfully created"

      When I follow "Project1"
      Then the "Spent" field within ".fields" should contain "11"
        And the "Q4 08-09" field within ".fields .spend" should contain "22"
        And the "Q1 09-10" field within ".fields .spend" should contain "33"
        And the "Q2 09-10" field within ".fields .spend" should contain "44"
        And the "Q3 09-10" field within ".fields .spend" should contain "55"
        And the "Q4 09-10" field within ".fields .spend" should contain "66"

        And the "Budget" field within ".fields" should contain "11"
        And the "Q4 08-09" field within ".fields .budget" should contain "22"
        And the "Q1 09-10" field within ".fields .budget" should contain "33"
        And the "Q2 09-10" field within ".fields .budget" should contain "44"
        And the "Q3 09-10" field within ".fields .budget" should contain "55"
        And the "Q4 09-10" field within ".fields .budget" should contain "66"

      When I follow "Edit" within ".funding_flows"
        And I fill in "Budget" with "7778" within ".fields"
        And I press "Update Project"
        And I follow "Project1"
      Then the "Budget" field within ".fields" should contain "7778"
