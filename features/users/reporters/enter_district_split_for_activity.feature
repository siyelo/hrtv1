Feature: NGO/donor can enter a code breakdown for each activity
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to break down activities into individual codes

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
  Given a refactor_me_please current_data_response for user "who_user"
  Given I am signed in as "who_user"


Scenario: See a breakdown for an activity
  Given a project with name "TB Treatment Project" in district "Karongi" and an existing response
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" and an existing response
  When I go to the activities page
  And I follow "Classify"
  Then I should see "TB Drugs procurement"
  And I should see "Budget by District"
  Then wait a few moments
  When I follow "Budget by District"
  Then show me the page
  Then wait a few moments
  Then show me the page
  Then I should see "Bugesera"
  And I should see "Karongi"
