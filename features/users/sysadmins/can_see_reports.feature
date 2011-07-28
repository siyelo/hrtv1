@run
Feature: Admin can see reports
  In order to increase funding
  As a sysadmin
  I want to be able to see reports

  Scenario: Navigate to reports page
    Given an organization exists with name: "SysAdmin Org"
	And a data_request exists with title: "dr1"
    And a sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
    And I am signed in as "sysadmin@hrtapp.com"
    And I follow "Reports" within the main nav
    Then I should see "Reports" within "h1"
