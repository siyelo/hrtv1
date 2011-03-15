Feature: Reporter can manage projects
  In order to track information
  As a reporter
  I want to be able to manage my projects

Background:
  Given a basic org + reporter profile, with data response, signed in

@reporters @projects @peter
Scenario: Browse to project edit page
  When I follow "My Data"
  And I follow "Projects"
  Then I should be on the projects page for response "Req1" org "UNDP"
  And I should see "Projects" within "div#sub-nav"

@reporters @projects
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

@reporters @projects
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
