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
  Given a data request with title "Req1" from "UNDP"
  Given a data response to "Req1" by "UNAIDS"
  Given the following projects 
     | name                 | request | organization |
     | TB Treatment Project | Req1    | UNAIDS       |
  Given the following funding flows 
     | to   | project              | from   | budget  |
     | UNDP | TB Treatment Project | UNAIDS | 1000.00 |
  Given I am signed in as "un_aids_user"
  When I follow "Dashboard"
  And I follow "Edit"
  And I follow "Implementers"
  Then I should see "TB Treatment Project"
  And I should see "UNDP"
  And I should see "1000.00"

Scenario: Creates an implementer funding flow
  Given an organization exists with name: "UNAIDS"
  And a data_request exists with title: "Req1", requesting_organization: the organization
  And a reporter exists with username: "un_aids_user", organization: the organization

  Given an organization exists with name: "WHO"

  Given an organization exists with name: "UNDP"
  And a reporter exists with username: "undp_user", organization: the organization
  And a data_response exists with data_request: the data_request, responding_organization: the organization
  And a project exists with name: "TB Treatment Project with more than 20 chars", data_response: the data_response

  Given an implementer "WHO" who we gave "20000000.00" for project "TB Treatment Project with more than 20 chars"

  Given I am signed in as "undp_user"
  When I follow "Dashboard"
  And I follow "Edit"
  When I follow "My Data"
  And I follow "Implementers"
  Then I should be on the implementers page
  And I should see "TB Treatment Project with more than 20 chars"
  And I should see "20,000,000.00"
