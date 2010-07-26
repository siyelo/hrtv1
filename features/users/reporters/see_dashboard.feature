Feature: NGO can see dashboard
  In order to ?
  As a NGO
  I want to be able to see a dashboard for relevant activities

Scenario: "See data requests"
<<<<<<< HEAD
  Given I am signed in as a reporter 
  When I go to the ngo dashboard page
=======
  Given I am on the ngo dashboard page
  Given I am signed in as a reporter
>>>>>>> 8759c7302f088bab26a59ee7174b861470f2ece6
  Then I should see "Data Requests to Fulfill"

