Feature: In order to reduce costs
  As a reporter
  I want to be able to manage my data response settings

Background:
  Given a basic org + reporter profile, with data response, signed in

@reporter_data_response
Scenario: Browse to data response edit page
  When I follow "My Data"
  And I follow "Settings"
  Then I should be on the data response page for "Req1"
  And I should see "Currency"

@reporter_data_response
Scenario Outline: Edit data response, see feedback messages
  When I go to the data response page for "Req1"
  And I fill in "data_response_currency" with "USD"
  And I fill in "data_response_fiscal_year_start_date" with "<start_date>"
  And I fill in "data_response_fiscal_year_end_date" with "<end_date>"
  And I press "Save"
  Then I should see "<message>"
  And I should see "<specific_message>"
  
  Examples:
    | start_date | end_date   | message                              | specific_message                          |
    | 2010-01-01 | 2010-01-02 | Successfully updated.                | Successfully updated.                     |
    |            | 2010-01-02 | Oops, we couldn't save your changes. | Fiscal year start date is an invalid date |
    | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date.     |

@reporter_data_response
Scenario: BUG: 5165708 - AS Comments breaking when validation errors on DResponse form
  When I go to the data response page for "Req1"
  And I fill in "data_response_fiscal_year_start_date" with ""
  And I fill in "data_response_fiscal_year_end_date" with ""
  And I press "Save"
  Then I should not see "Something went wrong, if this happens repeatedly, contact an administrator."

@reporter_data_response @javascript
Scenario: BUG: 5165708 - AS Comments breaking when validation errors on DResponse form
  When I go to the data response page for "Req1"
  And I fill in "data_response_fiscal_year_start_date" with ""
  And I fill in "data_response_fiscal_year_end_date" with ""
  And I press "Save"
  Then I should not see "ActionController::InvalidAuthenticityToken"

@reporter_data_response
Scenario Outline: Edit data response, see feedback messages
  When I go to the data response page for "Req1"
  And I fill in "data_response_currency" with "USD"
  And I fill in "data_response_fiscal_year_start_date" with "<start_date>"
  And I fill in "data_response_fiscal_year_end_date" with "<end_date>"
  And I press "Save"
  Then I should see "<message>"
  And I should see "<specific_message>"
  
  Examples:
    | start_date | end_date   | message                              | specific_message                          |
    | 2010-01-01 | 2010-01-02 | Successfully updated.                | Successfully updated.                     |
    |            | 2010-01-02 | Oops, we couldn't save your changes. | Fiscal year start date is an invalid date |
    | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date.     |

@reporter_data_response
Scenario: User can start a data response
  When I follow "Dashboard"
  And I follow "Edit"
  Then I should see "Currency"
  And I should see "Start of Fiscal Year 2008-2009"
  And I should see "End of Fiscal Year 2008-2009"
  And I should see "Point of Contact Name"
  And I should see "Point of Contact Position"
  And I should see "Point of Contact Phone Number"
  And I should see "Point of Contact Office Phone Number"
  And I should see "Point of Contact Office Location"
