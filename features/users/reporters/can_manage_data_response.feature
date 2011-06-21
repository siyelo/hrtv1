Feature: Reporter can manage data response
  In order to track information
  As a reporter
  I want to be able to manage data response

  Background:
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And a reporter exists with username: "reporter", organization: the organization
    And I am signed in as "reporter"

    Scenario: User can start a data response
      When I follow "Dashboard"
        And I follow "Edit"
      Then show me the page
      Then I should see "Response Settings" within "h1"


    Scenario: Browse to data response edit page
      When I follow "Settings"
      Then I should see "Settings" within "h1"


    Scenario Outline: Edit data response, see feedback messages
      Given a basic org + reporter profile, with data response, signed in
        And I follow "Settings"
        And I select "Euro (EUR)" from "Default Currency"
        And I fill in "Start of Fiscal Year" with "<start_date>"
        And I fill in "End of Fiscal Year" with "<end_date>"
        And I press "Update Response"
      Then I should see "<message>"
        And I should see "<specific_message>"

        Examples:
          | start_date | end_date   | message                              | specific_message                          |
          | 2010-01-01 | 2010-12-31 | Successfully updated.                | Successfully updated.                     |
          |            | 2010-01-02 | Oops, we couldn't save your changes. | Fiscal year start date can't be blank |
          | 123        | 2010-01-02 | Oops, we couldn't save your changes. | Fiscal year start date is not a valid date |
          | 2010-01-02 |            | Oops, we couldn't save your changes. | Fiscal year end date can't be blank |
          | 2010-01-02 | 123        | Oops, we couldn't save your changes. | Fiscal year end date is not a valid date |
          | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date.     |
