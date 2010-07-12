Feature: NGO/donor can enter a code breakdown for each activity 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to break down activities into individual codes

Scenario: See current activities to be broken down
  Given a project with name "TB Treatment Project"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" 
  When I go to the activity breakdown page
  Then I should see "Activity Breakdown"
  And I should see "TB Drugs procurement"
  And I should see "DEVELOPMENT OF SECTOR INSTITUTIONAL CAPACITY"
