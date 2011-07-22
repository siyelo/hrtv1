Feature: Activity Manager can see dashboard
  In order to
  As an Activity Manager
  I want to be able to see a dashboard for relevant activities

  Background:
    Given an organization exists
      And a data_request exists with title: "dr1", organization: the organization

      @run
  Scenario: See dashboard
    Given an nonreporting_organization exists with name: "DM ORG"
      # TODO: enable this, when DM location association is fixed
      #And a location exists with short_display: 'Bugesera'
      #, location_id: the location
      And an district_manager exists with email: "district_manager@hrtapp.com", organization: the nonreporting_organization
    When I am signed in as "district_manager@hrtapp.com"
    Then I should see "DM ORG: dr1"
      #And I should see "Bugesera"
      And I should see "Reports"
      And I should not see "Projects"
      And I should not see "Settings"
