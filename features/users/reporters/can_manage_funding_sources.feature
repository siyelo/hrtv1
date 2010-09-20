Feature: NGO/donor can see incoming funding flows for their projects 
  In order to ?
  As a NGO/Donor
  I want to be able to track incoming funding flows

@wip
Scenario: Reporter can see current incoming flows (Funding Sources) for their organization
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
    | Gates Foundation |
  Given the following reporters 
     | name         | organization |
     | who_user     | WHO          |
  Given the following projects 
     | name                 |
     | TB Treatment Project |
     | Some other Project   |
  Given the following funding flows 
     | to     | project              | from             | budget  |
     | WHO    | TB Treatment Project | UNAIDS           | 1000.00 |
     | UNAIDS | Some other Project   | Gates Foundation | 2000.00 |
  Given I am signed in as "who_user"
  When I go to the funding sources page
  Then I should see "TB Treatment Project"
  And I should not see "Some other Project"

Scenario: Create incoming funding flow
  Given a basic org + reporter profile, with data response, signed in
  Given a project with name "TB Treatment Project"
  When I go to the funding sources page
  And I follow "Create New"
  And I select "TB Treatment Project" from "Project"
  And I select "UNDP" from "From"
  And I fill in "Total Budget GOR FY 10-11" with "1000.00"
  And I press "Create"
  And I should see "TB Treatment Project"
  And I should see "UNDP"
  Then show me the page
  And I should see "1,000.00"

@wip
Scenario: BUG: 4335178 Redirected back to Funding Sources index after creation
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
