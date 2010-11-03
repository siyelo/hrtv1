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
  And I follow "Fix duplicate organizations"
  And I select "<duplicate>" from "Duplicate organization"
  And I select "<target>" from "Replacement organization"
  And I press "Replace"
  Then I should see "<message>"

  Examples:
    | duplicate | target             | message                                                  |
    | UNAIDS    | UNAIDS - 0 users   | Same organizations for duplicate and target selected.    |
    | UNAIDS    | WHO - 1 user       | Organizations successfully merged.                       |

@admin_organizations @javascript
Scenario Outline: Merge duplicate organizations (with JS)
  Given I am signed in as an admin
  When I go to the organizations page
  And I follow "Fix duplicate organizations"
  And I select "<duplicate>" from "Duplicate organization"
  And I should see "Organization: <duplicate_box>" within "#duplicate"
  And I select "<target>" from "Replacement organization"
  And I should see "Organization: <target_box>" within "#target"
  And I will confirm a js popup
  And I press "Replace"
  Then I should see "<message>"

  Examples:
    | duplicate | target           | duplicate_box | target_box | message                                                  |
    | UNAIDS    | UNAIDS - 0 users | UNAIDS        | UNAIDS     | Same organizations for duplicate and target selected.    |
    | UNAIDS    | WHO - 1 user     | UNAIDS        | WHO        | Organizations successfully merged.                       |
