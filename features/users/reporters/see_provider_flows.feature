Feature: NGO/donor can see incoming funding flows for their projects 
  In order to ?
  As a NGO/Donor
  I want to be able to track incoming funding flows

@run
Scenario: Create incoming funding flow
  Given an organization with name "UNDP"
  Given a reporter "Frank" in organization "UNDP"
  Given a project with name "TB Treatment Project"
  Given I am signed in as "Frank"
  When I go to the funding sources page
  And I follow "Create New"
  And I select "TB Treatment Project" from "Project"
  And I select "UNAIDS" from "From"
  And I enter "1000.00" in "Budget for GOR FY 10-11 (upcoming)"
  And I press "Create"
  Then I should be on the funding sources page
  And I should see "TB Treatment Project"
  And I should see "UNAIDS"
  And I should see "1000.00"
  