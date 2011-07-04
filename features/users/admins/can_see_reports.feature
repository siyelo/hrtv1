Feature: Admin can see reports
  In order to increase funding
  As an admin
  I want to be able to see reports

  Background:
    Given an organization exists
      And a data_request exists with title: "Req1", organization: the organization
      And an admin exists with username: "sysadmin", organization: the organization


    Scenario: Navigate to reports page
      And I am signed in as "sysadmin"
      When I follow "Home"
        And I follow "Reports" within the main nav
      Then I should see "Reports" within "h1"
