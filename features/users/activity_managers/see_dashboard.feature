Feature: Activity Manager can see dashboard
  In order to 
  As an Activity Manager
  I want to be able to see a dashboard for relevant activities

Scenario: "See data requests"
  Given I am signed in as an activity manager
  When I go to the reporter dashboard page
  Then I should see "Data Requests"

Scenario: See Projects/Implementers/etc tabs when a Data Req is selected
  Given the following organizations 
     | name   |
     | UNAIDS |
     | WHO    |
   Given the following activity managers 
     | name      | organization |
     | some_user | UNAIDS       |
  Given a data request with title "Some request" from "WHO"
  And I am signed in as "some_user" 
  When I go to the reporter dashboard page
  And I press "Respond"
  Then I should see the data response tabs
