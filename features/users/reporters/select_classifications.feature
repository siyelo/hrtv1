Feature: NGO/donor can enter a classifications for each activity 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to see classifications for activities

Background:
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
  Given the following reporters 
     | name         | organization |
     | who_user     | WHO          |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "WHO"
  Given a project with name "TB Treatment Project" for request "Req1" and organization "WHO"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project", request "Req1" and organization "WHO"
  Given I am signed in as "who_user"
  When I follow "Dashboard"
  And I follow "Edit"

Scenario: See a classification page for activities
  When I go to the classifications page
  Then I should see "WHO"
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
