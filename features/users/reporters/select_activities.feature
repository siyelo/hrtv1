Feature: NGO/donor can enter activities for each project 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to break down projects into activities

Scenario: See list of activities for my project
  Given a project with name "TB Treatment Project"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" 
  When I go to the projects listing page
  And I follow "Activities" within "div#as_projects-content"
  Then I should see "Activities for TB Treatment Project"
  And I should see "TB Drugs procurement"

@pending
Scenario: Add an activity
Scenario: Remove an activity
Scenario: Add activity across multiple projects


