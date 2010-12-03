Feature: NGO/donor can see incoming funding flows for their projects 
  In order to ?
  As a NGO/Donor
  I want to be able to track incoming funding flows

Background:
  Given a basic org + reporter profile, with data response, signed in

@wip
@reporter_funding_sources
Scenario: Reporter can see current incoming flows (Funding Sources) for their organization
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
    | GoR              |
    | Gates Foundation |
  Given the following reporters 
     | name         | organization |
     | who_user     | WHO          |
  Given a data request with title "Req1" from "GoR"
  Given a data response to "Req1" by "WHO"  
  Given the following projects 
     | name                 | request | organization |
     | TB Treatment Project | Req1    | WHO          |
     | Some other Project   | Req1    | WHO          |
  Given the following funding flows 
     | to     | project              | from             | budget  |
     | WHO    | TB Treatment Project | UNAIDS           | 1000.00 |
     | GoR    | Some other Project   | Gates Foundation | 2000.00 |
  Given I am signed in as "who_user"
  When I follow "Dashboard"
  And I follow "Edit"
  When I go to the funding sources page
  Then I should see "TB Treatment Project"
  And I should not see "Some other Project"

@reporter_funding_sources
Scenario: Create incoming funding flow
  When I go to the funding sources page
  And I follow "Create New"
  And I select "TB Treatment Project" from "Project"
  And I select "UNDP" from "From"
  And I fill in "Total Budget GOR FY 10-11" with "1000.00"
  And I press "Create"
  And I should see "TB Treatment Project"
  And I should see "UNDP"
  And I should see "1,000.00"

@reporter_funding_sources
Scenario: BUG: 4335178 Redirected back to Funding Sources index after creation
  When I go to the funding sources page
  And I follow "Create New"
  And I select "TB Treatment Project" from "Project"
  And I select "GoR" from "From"
  And I fill in "Total Budget GOR FY 10-11" with "1000.00"
  And I press "Create"
  Then I should be on the funding sources page
