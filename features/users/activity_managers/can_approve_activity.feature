Feature: Activity Manager can approve a code breakdown for each activity
  In order to increase the quality of information reported
  As a NGO/Donor Activity Manager
  I want to be able to approve activity splits

Background:
  Given an organization exists with name: "UNAIDS"
  And a data_request exists with title: "Req1", organization: the organization

  And an organization exists with name: "WHO"
  And a data_response exists with data_request: the data_request, organization: the organization
  And an activity_manager exists with username: "who_manager", organization: the organization, current_data_response: the data_response
  And a project exists with name: "TB Treatment Project", data_response: the data_response
  And an activity exists with name: "TB Drugs procurement", data_response: the data_response
  And the project is one of the activity's projects
  And mtef_code exists with short_display: "Mtef code"
  And I am signed in as "who_manager"

# note you cant drive this via the normal 'Classify' popup link in Capybara
# - it wont follow the new browser window
# The "wait a few moments" between checking the box and going to the next page is to avoid
# the ERROR Errno::EINVAL: Invalid argument -> webrick/httpresponse.rb:324:in `write'
# - I think capy just needs time to finish the ajax post request...
@activity_managers @approve_activity @javascript
Scenario: Approve an Activity
  When I go to the activity classification page for "TB Drugs procurement"
  Then I should see "Activity Classification"
  And I should see "Approved?"
  When I check "approve_activity"
  Then wait a few moments
  And I go to the activity classification page for "TB Drugs procurement"
  And the "approve_activity" checkbox should be checked

@activity_managers @approve_activity
Scenario: List approved activities
  When I go to the classifications page
  Then I should see "Approved?"
