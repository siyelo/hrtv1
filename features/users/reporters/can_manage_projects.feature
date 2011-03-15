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
  And I am signed in as "reporter"

Scenario: Browse to project edit page
  When I follow "data_request1"
  And I follow "Projects"
  Then I should see "Projects" within "h1"

Scenario: Reporter can CRUD projects
  When I follow "data_request1"
  And I follow "Projects"
  And I follow "Create Project"
  And I fill in "Name" with "Project1"
  And I fill in "Description" with "Project1 description"
  And I fill in "Start date" with "2011-01-01"
  And I fill in "End date" with "2011-12-01"
  And I press "Create New Project"
  Then I should see "Project was successfully created"
  And I should see "Project1"

  When I follow "Edit"
  And I fill in "Name" with "Project2"
  And I fill in "Description" with "Project2 description"
  And I press "Update Project"
  Then I should see "Project was successfully updated"
  And I should see "Project2"
  And I should not see "Project1"

  When I follow "Delete"
  Then I should see "Project was successfully destroyed"
  And I should not see "Project1"
  And I should not see "Project2"

Scenario Outline: Edit project dates, see feedback messages for start and end dates
  When I go to the projects page for response "Req1" org "UNDP"
  And I follow "Create Project"
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
  When I go to the projects page for response "Req1" org "UNDP" 
  And I follow "Create Project"
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
