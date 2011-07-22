Feature: District Manager can see district reports
  In order to
  As an District Manager
  I want to be able to see a district reports

  Background:
    Given an organization exists
      And a data_request exists with title: "dr1", organization: the organization


  Scenario: See dashboard
    Given an nonreporting_organization exists with name: "DM ORG"
      And a location exists with short_display: "Bugesera"
      And an district_manager exists with email: "district_manager@hrtapp.com", organization: the nonreporting_organization, location: the location
    When I am signed in as "district_manager@hrtapp.com"
      And I follow "Reports"
    Then the "reports" tab should be active
