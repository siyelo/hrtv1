Feature: NGO/donor can enter a code breakdown for each activity 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to break down activities into individual codes

Background:
  Given a project with name "TB Treatment Project"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" 
  Given I am signed in as a reporter 


# testing blocked by http://www.pivotaltracker.com/story/show/4544178

@wip
Scenario: enter expenditure for an activity, warns when child exceeds it.
  Given I am on the coding expenditure page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "111.00"
  And I fill in "Development Of Sector Institutional Capacity" with "112.00"
  Then I should see "Warning: value entered for this code exceeds it's parent amount."
