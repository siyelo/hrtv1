Feature: In order to reduce costs
  As a reporter
  I want to be able to manage my projects

Scenario: Browse to project edit page
  Given a basic org + reporter profile, with data response, signed in
  When I follow "My Data"
  And I follow "Projects"
  Then I should be on the projects page for "Req1"
  And I should see "Projects" within "div#main"

Scenario Outline: Edit project dates, see feedback messages for start and end dates
  Given a basic org + reporter profile, with data response, signed in
  When I go to the projects page for "Req1"
  And I follow "Create New"
  And I fill in "record_name_" with "Some Project"
  And I fill in "record_start_date_" with "<start_date>"
  And I fill in "record_end_date_" with "<end_date>"
  And I press "Create"
  Then I should see "<message>"
  And I should see "<specific_message>"
  
  Examples:
    | start_date | end_date   | message                              | specific_message                      |
    | 2010-01-01 | 2010-01-02 | Created Some Project                 | Created Some Project                  |
    |            | 2010-01-02 | Oops, we couldn't save your changes. | Start date is an invalid date         |
    | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date. |

Scenario Outline: Edit project dates, see feedback messages for Total budget and Total budget GOR
  Given a basic org + reporter profile, with data response, signed in
  When I go to the projects page for "Req1"
  And I follow "Create New"
  And I fill in "record_name_" with "Some Project"
  And I fill in "record_start_date_" with "2010-01-01"
  And I fill in "record_end_date_" with "2010-01-02"
  And I fill in "record_entire_budget_" with "<entire_budget>"
  And I fill in "record_budget_" with "<budget_gor>"
  And I press "Create"
  Then I should see "<message>"
  And I should see "<specific_message>"
  
  Examples:
    | entire_budget  | budget_gor | message                              | specific_message                                                     |
    | 900            | 800        | Created Some Project                 | Created Some Project                                                 |
    | 900            | 900        | Created Some Project                 | Created Some Project                                                 |
    | 900            | 1000       | Oops, we couldn't save your changes. | Total Budget must be less than or equal to Total Budget GOR FY 10-11 |

