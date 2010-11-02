Feature: Admin can approve a code breakdown for each activity 
  In order to increase the quality of information reported
  As an admin
  I want to be able to approve activity splits via the admin data response review screen

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
  Given a budget coding for "Delivering Services, Implementing Programs, Conducting Research" with amount "1000"
  
Scenario: See a budget coding breakdown
  Given I am signed in as an admin
  When I go to the admin review data response page for organization "WHO", request "Req1" 
  Then I should see "Delivering Services, Implementing Programs, Conducting Research"
  And I should see "1,000.00"

# NB: this scenario will only work for 1 activity, 1 classification
@javascript
Scenario: Approve a budget coding breakdown
  Given I am signed in as an admin
  When I go to the admin review data response page for organization "WHO", request "Req1" 
  When I click element "#project_details"
  And I click element ".project .descr"
  And I click element "#projects .activity_details"
  And I click element "#projects .activity .descr"
  Then I should see "Approved?"
  When I check "approve_activity"
  Then wait a few moments
  And I go to the admin review data response page for organization "WHO", request "Req1" 
  Then the "approve_activity" checkbox should be checked
