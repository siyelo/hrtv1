Feature: Reporter can enter a classifications for each activity
  In order to increase the quality of information reported
  As a reporter
  I want to be able to see classifications for activities

Background:
  Given a basic org + reporter profile, with data response, signed in

@reporters @classifications
Scenario: See a classification page for activities
  When I go to the classifications page
  Then I should see "UNDP"
  And I should see "Budget by Coding"
  And I should see "Budget by District"
  And I should see "Budget by Cost Category"
  And I should see "Expenditure by Coding"
  And I should see "Expenditure by District"
  And I should see "Expenditure by Cost Category"
  And I should see "Classify"

@pending
Scenario: Classified budget by coding
Scenario: Classified budget by district
Scenario: Classified budget by cost category
Scenario: Classified expenditure by coding
Scenario: Classified expenditure by district
Scenario: Classified expenditure by cost category
