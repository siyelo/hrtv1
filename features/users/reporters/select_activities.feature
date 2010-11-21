Feature: NGO/donor can enter activities for each project 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to break down projects into activities

Background:
  Given a basic org + reporter profile, with data response, signed in

Scenario: See list of activities for my project
  When I go to the activities page
  Then I should see "Activities" within "h2"
  And I should see "Create new activities from a file"

  #When I go to the activities page
  #Then I should see "Activities" within "h2"
  #And I should see "Create new activities from a file"

@pending
Scenario: Add an activity
Scenario: Remove an activity
Scenario: Add activity across multiple projects


