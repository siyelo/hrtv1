Feature: In order to reduce costs
  As a reporter
  I want to be able to manage my data response settings

@green
Scenario: Browse to data response edit page
  Given a basic org + reporter profile, with data response, signed in
  When I follow "My Data"
  And I follow "Configure"
  Then I should be on the data response page for "Req1"
  And I should see "Currency"

@green
Scenario Outline: Edit data response, see feedback messages
  Given a basic org + reporter profile, with data response, signed in
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


@green
Scenario: Comments should show on DResponse page
  Given a basic org + reporter profile, with data response, signed in
  And a model help for "DataResponse"
  When I go to the data response page for "Req1"
  Then I should see "General Questions / Comments"

@green
Scenario: BUG: 5165708 - AS Comments breaking when validation errors on DResponse form
  Given a basic org + reporter profile, with data response, signed in
  When I go to the data response page for "Req1"
  And I fill in "data_response_fiscal_year_start_date" with ""
  And I fill in "data_response_fiscal_year_end_date" with ""
  And I press "Save"
  Then I should not see "Something went wrong, if this happens repeatedly, contact an administrator."


@javascript
@green
Scenario: BUG: 5165708 - AS Comments breaking when validation errors on DResponse form
  Given a basic org + reporter profile, with data response, signed in
  When I go to the data response page for "Req1"
  And I fill in "data_response_fiscal_year_start_date" with ""
  And I fill in "data_response_fiscal_year_end_date" with ""
  And I press "Save"
  And I should not see "ActionController::InvalidAuthenticityToken"

@green
Scenario: See data response form
  Given the following organizations 
    | name   |
    | UNDP   |
    | UNAIDS |
  Given the following reporters 
     | name         | organization |
     | undp_user    | UNDP         |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "UNDP"
  Given I am signed in as "undp_user"
  When I follow "Dashboard"
  And I follow "Edit"
  When I follow "My Data"
  And I follow "Configure"
  Then I should be on the data response page for "Req1"
  And I should see "Currency"

@green
Scenario Outline: Edit data response, see feedback messages
  Given a basic org + reporter profile, with data response, signed in
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

@green
Scenario: User can start a data response
  Given the following organizations 
    | name   |
    | UNDP   |
    | UNAIDS |
  Given the following reporters 
     | name         | organization |
     | undp_user    | UNDP         |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "UNDP"
  Given I am signed in as "undp_user"
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
