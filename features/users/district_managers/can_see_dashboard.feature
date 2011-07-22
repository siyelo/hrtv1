Feature: District Manager can see dashboard
  In order to
  As an District Manager
  I want to be able to see a dashboard for relevant activities

  Scenario: See dashboard
    Given an organization exists
      And a data_request exists with title: "dr1", organization: the organization
      And an nonreporting_organization exists with name: "DM ORG"
      And a location exists with short_display: "Bugesera"
      And an district_manager exists with email: "district_manager@hrtapp.com", organization: the nonreporting_organization, location: the location
    When I am signed in as "district_manager@hrtapp.com"
    Then I should see "Bugesera"
      And I should see "Getting started as a District Manager"
      And I should see "Reports"
      And I should not see "Projects"
      And I should not see "Settings"

  Scenario: Can Switch between requests
    Given an organization exists
      And a data_request exists with title: "dr1", organization: the organization
      And a data_request exists with title: "dr2", organization: the organization
      And an nonreporting_organization exists with name: "ORG"
      And a location exists with short_display: "Bugesera"
      And an district_manager exists with email: "district_manager@hrtapp.com", organization: the nonreporting_organization, location: the location
    When I am signed in as "district_manager@hrtapp.com"
    Then I should see "ORG: [dr2]"
    When I follow "dr1"
    Then I should see "ORG: [dr1]"
