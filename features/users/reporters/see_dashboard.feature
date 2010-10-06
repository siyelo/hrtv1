Feature: NGO can see dashboard
  In order to ?
  As a NGO
  I want to be able to see a dashboard for relevant activities

Scenario: "See data requests"
  Given I am signed in as a reporter 
  When I go to the reporter dashboard page
  Then I should see "Data Requests to Fulfill"

@green
Scenario: See Projects/Implementers/etc tabs when a Data Req is selected
  Given the following organizations 
     | name             |
     | UNAIDS           |
     | WHO              |
   Given the following reporters 
      | name           | organization |
      | some_user     | UNAIDS       |
  Given a data request with title "Some request" from "WHO"
  And I am signed in as "some_user" 
  When I go to the reporter dashboard page
  And I press "Respond"
  Then I should see the data response tabs
  
Scenario: Bug: should not see Projects/Implementers/etc tabs until a Data Req is selected
  Given I am signed in as a reporter 
  When I go to the reporter dashboard page
  Then I should not see the data response tabs


Scenario: Bug: Workplan tab appears active even on Dashboard
  Given I am signed in as a reporter 
  When I go to the reporter dashboard page
  Then I should see "Dashboard" within "#main-nav li.active"
  And I should not see "Workplan" within "#main-nav li.active"

