Feature: Manage organizations
  In order to have good organizations in the system
  As an admin
  I want to be able to manage organizations

Background:
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
  Given the following reporters 
     | name         | organization |
     | who_user     | WHO          |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "WHO"
  
@admin_organizations
Scenario Outline: Merge duplicate organizations
  Given I am signed in as an admin
  When I go to the organizations page
  And I follow "Merge duplicate organization"
  And I select "<duplicate>" from "Duplicate organization"
  And I select "<target>" from "Target organization"
  And I press "Merge"
  Then I should see "<message>"

  Examples:
    | duplicate | target   | message                                                  |
    | UNAIDS    | UNAIDS   | Same organizations for duplicate and target selected.    |
    | UNAIDS    | WHO      | Organizations successfully merged.                       |
