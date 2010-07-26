Feature: NGO/donor can enter a code breakdown for each activity 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to break down activities into individual codes

Scenario: See a breakdown for an activity
  Given a project with name "TB Treatment Project"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" 
  Given I am signed in as a reporter 
  When I go to the activities page
  And I follow "Classify"
  And I should see "TB Drugs procurement"
<<<<<<< HEAD
  Then I should see "Development Of Sector Institutional Capacity"
=======
  #Then I should see "DEVELOPMENT OF SECTOR INSTITUTIONAL CAPACITY"
>>>>>>> 8759c7302f088bab26a59ee7174b861470f2ece6

Scenario: See a checkbox and amount for each code
