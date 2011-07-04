Feature: Activity Manager can see dashboard
  In order to
  As an Activity Manager
  I want to be able to see a dashboard for relevant activities

  Background:
    Given an organization exists with name: "admin_org"
      And a data_request exists with title: "dr1", organization: the organization


    Scenario: See dashboard
      Given an organization exists with name: "Test Org"
        And an activity_manager exists with username: "Frank", organization: the organization
        And I am signed in as "Frank"
      Then I should see "Organizations I Manage"
