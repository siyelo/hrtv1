Feature: Reporter can manage long term budgets
  In order to increase the quality of information reported
  As a reporter
  I want to be able to manage long term budgets

  @cant_be_tested
  Scenario: Reporter can Add long term budgets
    Given an organization exists
      And a data_request exists with organization: the organization
      And a user exists with email: "reporter@hrtapp.com"
      And I am signed in as "reporter@hrtapp.com"
    When I follow "Projects"
      And I follow "Future Budgets"
