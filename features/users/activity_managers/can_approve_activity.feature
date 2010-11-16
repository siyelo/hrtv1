Feature: Activity Manager can approve a code breakdown for each activity 
  In order to increase the quality of information reported
  As a NGO/Donor Activity Manager
  I want to be able to approve activity splits

Background:
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
  Given the following activity managers 
     | name            | organization |
     | who_manager     | WHO          |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "WHO"
  Given a project with name "TB Treatment Project" for request "Req1" and organization "WHO"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project", request "Req1" and organization "WHO"
  Given I am signed in as "who_manager"
  When I follow "Dashboard"
  And I follow "Edit"

@run
Scenario: See a breakdown for an activity
  When I go to the activities page
  And I follow "Classify"
  Then I should see "TB Drugs procurement"
  And I should see "Coding" within "#tab1"
  And I should see "District" within "#tab2"
  And I should see "Categorization" within "#tab3"
  And I should see "Coding" within "#tab4"
  And I should see "District" within "#tab5"
  And I should see "Cost Categorization" within "#tab6"
  And I should see "Providing Technical Assistance"


# note you cant drive this via the normal 'Classify' popup link in Capybara 
# - it wont follow the new browser window 
# The "wait a few moments" between checking the box and going to the next page is to avoid 
# the ERROR Errno::EINVAL: Invalid argument -> webrick/httpresponse.rb:324:in `write'
# - I think capy just needs time to finish the ajax post request...
@javascript
Scenario: Approve an Activity
  When I go to the activity classification page for "TB Drugs procurement"
  Then I should see "Activity Classification"
  And I should see "Approved?"
  When I check "approve_activity"
  Then wait a few moments
  And I go to the activity classification page for "TB Drugs procurement"
  Then the "approve_activity" checkbox should be checked

Scenario: List approved activities
  When I go to the classifications page
  Then I should see "Approved?"
