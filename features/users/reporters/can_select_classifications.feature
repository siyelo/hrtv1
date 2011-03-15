Feature: Reporter can enter a classifications for each activity
  In order to increase the quality of information reported
  As a reporter
  I want to be able to see classifications for activities

Background:
  Given a basic org + reporter profile, with data response, signed in

Scenario: See a classification page for activities
  When I go to the classifications page
  Then I should see "UNDP"
  And I should see "Budget by Purposes"
  And I should see "Budget by Locations"
  And I should see "Budget by Inputs"
  And I should see "Expenditure by Purposes"
  And I should see "Expenditure by Locations"
  And I should see "Expenditure by Inputs"
  And I should see "Classify"

@pending
Scenario: Classified budget by coding
Scenario: Classified budget by district
Scenario: Classified budget by cost category
Scenario: Classified expenditure by coding
Scenario: Classified expenditure by district
Scenario: Classified expenditure by cost category
