Feature: Activity Manager can download formatted workplan
  In order to reduce costs
  As an Activity Manager
  I want to be able to download reports of the organizations I manage

  Background:
    Given an organization "admin_org" exists with name: "admin_org"
      And a data_request exists with organization: the organization
      And an organization "reporter_org" exists with name: "reporter_org"
      And a reporter exists with organization: the organization "reporter_org"
      And an organization "ac_org" exists with name: "ac_org"
      And an activity_manager exists with email: "activity_manager@hrtapp.com", organization: the organization "ac_org"
      And organization "reporter_org" is one of the activity_manager's organizations
      And I am signed in as "activity_manager@hrtapp.com"


  Scenario: Activity manager can download workplan
    When I follow "reporter_org"
      And I follow "Download Workplan"
    Then I should receive a csv file


  Scenario: Activity manager can quick-download workplan from AM Dashboard page
    When I follow "Download Workplan"
    Then I should receive a csv file
