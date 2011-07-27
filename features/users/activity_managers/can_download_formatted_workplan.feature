Feature: Activity Manager can download formatted workplan
  In order to reduce costs
  As an Activity Manager
  I want to be able to download reports of the organizations I manage

  Background:
    Given an organization "admin_org" exists with name: "admin_org"
      And a data_request exists with title: "dr1", organization: the organization
      And an organization "reporter_org" exists with name: "reporter_org"
      And a reporter exists with organization: the organization
      And an organization "ac_org" exists with name: "ac_org"
      And an activity_manager exists with email: "activity_manager@hrtapp.com", organization: the organization
      And organization "reporter_org" is one of the activity_manager's organizations
      And I am signed in as "activity_manager@hrtapp.com"

  @javascript
  Scenario: See workplan option in menu
    Given I follow "reporter_org"
    And I follow "Import / Export"
    Then I should see "Export Workplan"

  # this cannot be run with @javascript - gives a capy NotSupportedByDriverError
  Scenario: Download workplan
    Given I follow "reporter_org"
    And I follow "Export Workplan"
    Then I should receive a csv file

  Scenario: quick-download workplan from AM Dashboard page
    When I follow "Export Workplan"
    Then I should receive a csv file
