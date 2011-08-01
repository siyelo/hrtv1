Feature: Reporter can edit settings
  In order to setup my organization
  As a reporter
  I want to be able to edit settings

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And I am signed in as "reporter@hrtapp.com"

    Scenario: Reporter can edit organization settings
      When I follow "Settings"
        And I fill in "Contact name" with "Pink Panther"
        And I fill in "Contact position" with "Panther"
        And I fill in "Phone number" with "3423423424"
        And I fill in "Office number" with "3242343242"
        And I fill in "Office location" with "Japan"
        And I select "Euro (EUR)" from "Default Currency"
        And I press "Save Settings"
      Then I should see "Successfully updated"

