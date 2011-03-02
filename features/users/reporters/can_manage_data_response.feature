Feature: Reporter can manage data response
  In order to track information
  As a reporter
  I want to be able to manage data response

Background:
  
@reporters @data_response
@run
Scenario: User can start a data response
  Given a data_request exists with title: "Req1"
  Given a basic org + reporter profile, signed in
  When I follow "Dashboard"
  And I follow "Respond"
  Then I should see "New Response" within "h1"

@reporters @data_response
@run
Scenario: Browse to data response edit page
  Given a basic org + reporter profile, with data response, signed in
  When I follow "My Data"
  And I follow "Settings"
  And I should see "Response Settings" within "h1"

@reporters @data_response
@run
Scenario Outline: Edit data response, see feedback messages
  Given a basic org + reporter profile, with data response, signed in
  When I follow "My Data"
  And I follow "Settings"
  And I select "Euro (EUR)" from "data_response_currency"
  And I fill in "data_response_fiscal_year_start_date" with "<start_date>"
  And I fill in "data_response_fiscal_year_end_date" with "<end_date>"
  And I press "Update Response"
  Then I should see "<message>"
  And I should see "<specific_message>"

  Examples:
    | start_date | end_date   | message                              | specific_message                          |
    | 2010-01-01 | 2010-01-02 | Successfully updated.                | Successfully updated.                     |
    |            | 2010-01-02 | Oops, we couldn't save your changes. | Fiscal year start date is an invalid date |
    | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date.     |

@reporters @data_response

Scenario: BUG: 5165708 - AS Comments breaking when validation errors on DResponse form
  Given a basic org + reporter profile, with data response, signed in
  When I go to the data response page for "Req1"
  And I fill in "data_response_fiscal_year_start_date" with ""
  And I fill in "data_response_fiscal_year_end_date" with ""
  And I press "Update Response"
  Then I should not see "Something went wrong, if this happens repeatedly, contact an administrator."

@reporters @data_response @javascript
Scenario: BUG: 5165708 - AS Comments breaking when validation errors on DResponse form
  Given a basic org + reporter profile, with data response, signed in
  When I go to the data response page for "Req1"
  And I fill in "data_response_fiscal_year_start_date" with ""
  And I fill in "data_response_fiscal_year_end_date" with ""
  And I press "Update Response"
  Then I should not see "ActionController::InvalidAuthenticityToken"

@reporters @data_response
Scenario Outline: Edit data response, see feedback messages
  Given a basic org + reporter profile, with data response, signed in
  When I go to the data response page for "Req1"
  And I select "Euro (EUR)" from "data_response_currency"
  And I fill in "data_response_fiscal_year_start_date" with "<start_date>"
  And I fill in "data_response_fiscal_year_end_date" with "<end_date>"
  And I press "Update Response"
  Then I should see "<message>"
  And I should see "<specific_message>"

  Examples:
    | start_date | end_date   | message                              | specific_message                          |
    | 2010-01-01 | 2010-01-02 | Successfully updated.                | Successfully updated.                     |
    |            | 2010-01-02 | Oops, we couldn't save your changes. | Fiscal year start date is an invalid date |
    | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date.     |

