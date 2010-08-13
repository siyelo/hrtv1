Feature: NGO can see dashboard
  In order to ?
  As a NGO
  I want to be able to see a dashboard for relevant activities

Scenario: "See data requests"
  Given I am signed in as a reporter 
  When I go to the ngo dashboard page
  Then I should see "Data Requests to Fulfill"

