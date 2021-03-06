Feature: Reporter can manage data response
  In order to track information
  As a reporter
  I want to be able to manage data response

  Background:
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a data_response should exist with data_request: the data_request, organization: the organization
    And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
    And I am signed in as "reporter@hrtapp.com"
    And I follow "Settings"

  Scenario Outline: Reporter can edit settings and see feedback messages
    When I select "Euro (EUR)" from "Default Currency"
      And I should not see "Fosaid"
      And I fill in "Start of Fiscal Year" with "<start_date>"
      And I fill in "End of Fiscal Year" with "<end_date>"
      And I press "Update organization"
    Then I should see "<message>"
      And I should see "<specific_message>"

      Examples:
        | start_date | end_date   | message                              | specific_message                      |
        | 2010-01-01 | 2010-12-31 | Settings were successfully updated.  | Settings were successfully updated.   |
        |            | 2010-01-02 | Oops, we couldn't save your changes. | can't be blank                        |
        | 123        | 2010-01-02 | Oops, we couldn't save your changes. | is not a valid date                   |
        | 2010-01-02 |            | Oops, we couldn't save your changes. | The end date must be exactly one year |
        | 2010-01-02 | 123        | Oops, we couldn't save your changes. | is not a valid date                   |
        | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | The end date must be exactly one year |
