Feature: NGO/donor can see incoming funding flows for their projects 
  In order to ?
  As a NGO/Donor
  I want to be able to track incoming funding flows

Scenario: Create incoming funding flow
  Given an organization with name "UNDP"
  Given a reporter "Frank" in organization "UNDP"
  Given a project with name "TB Treatment Project"
  Given I am signed in as "Frank"
  When I go to the funding sources page
  And I follow "Create New"
  And I select "TB Treatment Project" from "Project"
  And I select "UNAIDS" from "From"
  And I fill in "Budget for GOR FY 10-11 (upcoming)" with "1000.00"
  And I press "Create"
  And I should see "TB Treatment Project"
  And I should see "UNAIDS"
  And I should see "1000.00"

Scenario: BUG: Redirected back to Funding Sources index after creation
  Given an organization with name "UNDP"
  Given a reporter "Frank" in organization "UNDP"
  Given a project with name "TB Treatment Project"
  Given I am signed in as "Frank"
  When I go to the funding sources page
  And I follow "Create New"
  And I select "TB Treatment Project" from "Project"
  And I select "UNAIDS" from "From"
  And I fill in "Budget for GOR FY 10-11 (upcoming)" with "1000.00"
  And I press "Create"
  Then I should be on the funding sources page


#BUG This test seems valid, but currently failing - expect its to do with incorrect scoping

@run
Scenario: Other organization creates a Funding Source, we see it under our Providers list
  Given the following organizations 
    | name   |
    | UNDP   |
    | UNAIDS |
  Given the following reporters 
     | name         | organization |
     | undp_user    | UNDP         |
     | un_aids_user | UNAIDS       |
  Given the following projects 
     | name                 |
     | TB Treatment Project |
  Given the following funding flows 
     | to   | project              | from   | budget  |
     | UNDP | TB Treatment Project | UNAIDS | 1000.00 |
  Given I am signed in as "un_aids_user"
  When I go to the providers page
  Then show me the page
  Then debug
  Then I should see "TB Treatment Project"
  And I should see "UNDP"
  And I should see "1000.00"