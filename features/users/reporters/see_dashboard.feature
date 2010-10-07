Feature: NGO can see dashboard
  In order to ?
  As a NGO
  I want to be able to see a dashboard for relevant activities

Scenario: "See data requests"
  Given I am signed in as a reporter 
  When I go to the reporter dashboard page
  Then I should see "Donor/NGO Dashboard"

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
  
Scenario: See unfulfilled/current Data Requests listed 
  Given the following organizations 
     | name             |
     | UNAIDS           |
     | WHO              |
   Given the following reporters 
      | name          | organization |
      | some_user     | UNAIDS       |
  Given a data request with title "Request1" from "WHO"
  Given a data request with title "Request2" from "WHO"
  Given a data response to "Request1" by "UNAIDS"
  And I am signed in as "some_user" 
  When I go to the reporter dashboard page
  Then I should see "Request1" within ".current_request"
  And I should see "Request2" within ".unfulfilled_request"
  
Scenario: Bug: should not see Projects/Implementers/etc tabs until a Data Req is selected
  Given I am signed in as a reporter 
  When I go to the reporter dashboard page
  Then I should not see the data response tabs

Scenario: Bug: Workplan tab appears active even on Dashboard
  Given I am signed in as a reporter 
  When I go to the reporter dashboard page
  Then I should see "Dashboard" within "#main-nav li.active"
  And I should not see "Workplan" within "#main-nav li.active"

