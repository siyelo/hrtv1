Feature: Reporter can manage future budgets
  In order to increase the quality of information reported
  As a reporter
  I want to be able to manage future budgets

  @wip
  Scenario: Reporter can Add future budgets
    Given an organization exists
      And a data_request exists with organization: the organization
      And a user exists with email: "reporter@hrtapp.com"
      And I am signed in as "reporter@hrtapp.com"
    When I follow "Projects"
      And I follow "Future Budgets"


