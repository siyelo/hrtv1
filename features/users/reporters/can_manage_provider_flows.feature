Feature: NGO/donor can manage outgoing funding flows for their projects 
  In order to ?
  As a NGO/Donor
  I want to be able to track outgoing funding flows

#BUG This test seems valid, but currently failing - expect its to do with incorrect scoping

Scenario: List current outgoing flows

Scenario: Create outgoing flow

@wip
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
  Then I should see "TB Treatment Project"
  And I should see "UNDP"
  And I should see "1000.00"
  
Scenario: Creates an implementer funding flow
  Given the following organizations 
    | name   |
    | UNDP   |
    | UNAIDS |
    | WHO    |
  Given the following reporters 
     | name         | organization |
     | undp_user    | UNDP         |
     | un_aids_user | UNAIDS       |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "UNDP"
  Given a project with name "TB Treatment Project with more than 20 chars" and an existing response
  Given an implementer "WHO" for project "TB Treatment Project with more than 20 chars"  and an existing response
  Given a refactor_me_please current_data_response for user "undp_user"
  Given I am signed in as "undp_user"
  When I follow "My Data"
  And I follow "Implementers"
  Then I should be on the implementers page
  And I should see "TB Treatment Project with more than 20 chars"
