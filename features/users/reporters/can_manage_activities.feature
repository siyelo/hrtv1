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
    And a project exists with name: "project1", budget: "20000", data_response: the data_response
    And a location exists with short_display: "Location1"
    And the location is one of the project's locations
    And a location exists with short_display: "Location2"
    And the location is one of the project's locations
    And I am signed in as "reporter"
    And I follow "data_request1"
    And I follow "Projects"


    @javascript
    Scenario: Reporter can CRUD activities
      When I follow "Add" within ".sub-head:nth-child(2)"
        And I fill in "Name" with "activity1"
        And I fill in "Description" with "1ctivity1 description"
        And I fill in "Start date" with "2011-01-01"
        And I fill in "End date" with "2011-12-01"
        And I select "project1" from "Project"
        And I check "Location1"
        And I check "Location2"
        And I press "Save & Classify >"
      Then I should see "Activity was successfully created"
        #And I should see "activity1"
        #And I should see "Location1, Location2"

      When I follow "activity1"
        And I fill in "Name" with "activity2"
        And I fill in "Description" with "activity2 description"
        And I uncheck "Location2"
        And I press "Save & Classify >"
      Then I should see "Activity was successfully updated"
        #And I should see "activity2"
        #And I should not see "activity1"
        #And I should see "Location1"
        #And I should not see "Location2"

      When I follow "activity2"
        And I confirm the popup dialog
        And I follow "Delete this Activity"
      Then I should see "Activity was successfully destroyed"
        #And I should not see "activity1"
        #And I should not see "activity2"


    Scenario Outline: Reporter can CRUD activities and see errors
      When I follow "Add" within ".sub-head:nth-child(2)"
        And I fill in "Name" with "<name>"
        And I fill in "Description" with "activity description"
        And I fill in "Start date" with "<start_date>"
        And I fill in "End date" with "<end_date>"
        And I select "<project>" from "Project"
        And I press "Save & Classify >"
      Then I should see "Oops, we couldn't save your changes."
        And I should see "<message>"

        Examples:
           | name | start_date | end_date   | project  | message                       |
           #|      | 2011-01-01 | 2011-12-01 | project1 | Name can't be blank           |
           #| a1   |            | 2011-12-01 | project1 | Start date is an invalid date |
           #| a1   | 2011-01-01 |            | project1 | End date is an invalid date   |
           | a1   | 2011-01-01 | 2011-12-01 |          | Project can't be blank        |

    Scenario: Reporter can enter 5 year budget projections
     When I follow "Add" within ".sub-head:nth-child(2)"
      And I fill in "Name" with "Activity1"
      And I fill in "Description" with "Activity1 description"
      And I fill in "Start date" with "2011-01-01"
      And I fill in "End date" with "2011-12-01"
      And I select "project1" from "Project"
      And I fill in "Budget" with "10000"
      And I fill in "Year + 2" with "2000"
      And I fill in "Year + 3" with "3000"
      And I fill in "Year + 4" with "4000"
      And I fill in "Year + 5" with "5000"
      And I press "Save & Classify >"
     Then I should see "Activity was successfully created"

      When I follow "Activity1"
      Then the "Budget" field should contain "1000"
        And the "Year + 2" field should contain "2000"
        And the "Year + 3" field should contain "3000"
        And the "Year + 4" field should contain "4000"
        And the "Year + 5" field should contain "5000"


    Scenario: A reporter can create comments for an activity
      Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
      When I follow "Projects"
       And I follow "Activity1 description"
       And I fill in "Title" with "Comment title"
       And I fill in "Comment" with "Comment body"
       And I press "Create Comment"
      Then I should see "Comment title"
       And I should see "Comment body"


    Scenario: Reporter can upload activities
      When I attach the file "spec/fixtures/activities.csv" to "File" within ".activities_upload_box"
        And I press "Import" within ".activities_upload_box"
      Then I should see "Activities Bulk Create"


    Scenario: Reporter can see error if no csv file is not attached for upload
      When I press "Import" within ".activities_upload_box"
      Then I should see "Please select a file to upload activities"


    Scenario: Adding malformed CSV file doesn't throw exception
      When I attach the file "spec/fixtures/malformed.csv" to "File"
        And I press "Import"
      Then I should see "Your CSV file does not seem to be properly formatted"


    Scenario: Reporter can download Activities CSV template
      When I follow "Get Template" within ".activities_upload_box"
      Then I should see "Project Name,Activity Name,Activity Description,Provider,Spend,Q1 Spend,Q2 Spend,Q3 Spend,Q4 Spend,Budget,Q1 Budget,Q2 Budget,Q3 Budget,Q4 Budget,Districts,Beneficiaries,Outputs / Targets,Start Date,End Date"


      @run
    Scenario: Reporter can download Activities
      Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
      When I follow "Projects"
        And I follow "Export" within ".upload_box"
      Then I should see "Activity1"
        And I should see "Activity1 description"

    Scenario: A reporter can create comments for an activity and see comment errors
      Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
      When I follow "Projects"
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


    Scenario: Does not email users when a comment is made by a reporter
      Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
        And no emails have been sent
      When I follow "Projects"
        And I follow "Activity1 description"
        And I fill in "Comment" with "Comment body"  
        And I fill in "Title" with "Comment title"
        And I fill in "Comment" with "Comment body"
        And I press "Create Comment"
      Then "reporter_1@example.com" should not receive an email
      

    Scenario: A reporter can select implementer for an activity
      When I follow "Add" within ".sub-head:nth-child(2)"
      # check if by default reporter organization is selected
      Then I select "organization2" from "Implementer"

      When I fill in "Name" with "Activity1"
        And I fill in "Description" with "Activity1 description"
        And I select "organization1" from "Implementer"
        And I select "project1" from "Project"
        And I fill in "Start date" with "2011-01-01" 
        And I fill in "End date" with "2011-03-01"
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


    @javascript
    Scenario: A reporter can create funding sources for an activity
      Given an organization "funding_organization1" exists with name: "funding_organization1"
        And a funding_flow exists with from: organization "funding_organization1", to: organization "my_organization", project: the project, data_response: the data_response
        And an organization "funding_organization2" exists with name: "funding_organization2"
        And a funding_flow exists with from: organization "funding_organization2", to: organization "my_organization", project: the project, data_response: the data_response
      When I follow "Add" within ".sub-head:nth-child(2)"
        And I fill in "Name" with "Activity1"
        And I fill in "Description" with "Activity1 description"
        And I fill in "Start date" with "2011-01-01" 
        And I fill in "End date" with "2011-03-01"
        And I select "project1" from "Project"
        And I follow "Add funding source"
        And I select "funding_organization1" from "Organization" within ".fields"
        And I fill in "Spent" with "111" within ".fields"
        And I fill in "Budget" with "222" within ".fields"
        And I press "Save & Classify >"
      Then I should see "Activity was successfully created"
        And I follow "Projects"

      When I follow "Activity1 description"
        And I follow "Edit" within ".fields"
        And I select "funding_organization2" from "Organization" within ".fields"
        And I fill in "Spent" with "333" within ".fields"
        And I fill in "Budget" with "444" within ".fields"
        And I press "Save & Classify >"
      Then I should see "Activity was successfully updated"


  Scenario: If the data_request budget is not checked the budget should not show up in the activities screen
      Given I follow "Sign Out"
      And an organization exists with name: "organization5"
      And a data_request exists with title: "data_request2", budget: false
      And a data_response exists with data_request: the data_request, organization: the organization
      And a reporter exists with username: "reporter2", organization: the organization
      And a location exists with short_display: "Location1"
      And a location exists with short_display: "Location2"
      And I am signed in as "reporter2"
      And I follow "data_request2"
      And a project exists with name: "project1", data_response: the data_response
      And I follow "Projects"
      When I follow "Add" within ".sub-head:nth-child(2)"
      Then I should not see "Budget (planned expenditure)"
      And  I should see "Past Activity Expenditure"
      
  Scenario: If the data_request has not got a budget or a spend then only the save button should appear
    Given I follow "Sign Out"
    And a data_request "data_request10" exists with title: "THE DATA_REQUEST", spend: false, budget: false
    And a data_response "data_response10" exists with data_request: data_request "data_request10", organization: organization "my_organization"
    And a project exists with name: "project19", data_response: data_response "data_response10"
    And a activity exists with project: the project, name: "activity14", description: "act14desc"
    And I am signed in as "reporter"
    And I follow "THE DATA_REQUEST"
    And I follow "Projects"
    When I follow "Add" within ".sub-head:nth-child(2)"
      And I fill in "Name" with "activity1"
      And I fill in "Description" with "1ctivity1 description"
      And I fill in "Start date" with "2011-01-01"
      And I fill in "End date" with "2011-12-01"
      And I select "project1" from "Project"
    Then I should see "Save" button
    And I should not see "Save & Classify >" button
