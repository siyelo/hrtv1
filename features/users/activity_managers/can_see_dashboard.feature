Feature: Activity Manager can see dashboard
  In order to
  As an Activity Manager
  I want to be able to see a dashboard for relevant activities

  Background:
    Given an organization exists
      And a data_request exists with title: "dr1", organization: the organization

  Scenario: See dashboard
    Given an organization exists
      And an activity_manager exists with email: "activity_manager@hrtapp.com", organization: the organization
      And I am signed in as "activity_manager@hrtapp.com"
    Then I should see "Organizations I Manage"
