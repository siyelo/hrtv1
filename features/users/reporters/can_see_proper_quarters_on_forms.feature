Feature: Reporter can see proper fiscal year quarters on projects form
  In order to report in fiscal year quarters
  As an Reporter
  I want to be able to see a proper fiscal year quarters

  Scenario: See FY quarters on activity form for GOR FY
    Given now is "2010-07-15"
      And an organization exists with fiscal_year_start_date: "2010-07-01", fiscal_year_end_date: "2011-06-30"
      And a data_request exists
      And a data_response should exist with data_request: data_request
      And a project exists with data_response: the data_response
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And I am signed in as "reporter@hrtapp.com"
      And I follow "Projects"
      And I follow "Add Activities now"

    # spend
    Then I should not see "Apr '09 - Jun '09" within ".js_spend_quarters"
      And I should see "Jul '09 - Sep '09" within ".js_spend_quarters"
      And I should see "Oct '09 - Dec '09" within ".js_spend_quarters"
      And I should see "Jan '10 - Mar '10" within ".js_spend_quarters"
      And I should see "Apr '10 - Jun '10" within ".js_spend_quarters"
      And I should not see "Jul '10 - Sep '10" within ".js_spend_quarters"

      # budget
      And I should not see "Apr '10 - Jun '10" within ".js_budget_quarters"
      And I should see "Jul '10 - Sep '10" within ".js_budget_quarters"
      And I should see "Oct '10 - Dec '10" within ".js_budget_quarters"
      And I should see "Jan '11 - Mar '11" within ".js_budget_quarters"
      And I should see "Apr '11 - Jun '11" within ".js_budget_quarters"
      And I should not see "Jul '11 - Sep '11" within ".js_budget_quarters"


  Scenario: See FY quarters on activity form for USG FY
    Given now is "2010-10-15"
      And an organization exists with fiscal_year_start_date: "2010-10-01", fiscal_year_end_date: "2011-09-30"
      And a data_request exists
      And a data_response should exist with data_request: data_request
      And a project exists with data_response: the data_response
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And I am signed in as "reporter@hrtapp.com"
      And I follow "Projects"
      And I follow "Add Activities now"

    # spend
    Then I should not see "Apr '09 - Jun '09" within ".js_spend_quarters"
      And I should see "Jul '09 - Sep '09" within ".js_spend_quarters"
      And I should see "Oct '09 - Dec '09" within ".js_spend_quarters"
      And I should see "Jan '10 - Mar '10" within ".js_spend_quarters"
      And I should see "Apr '10 - Jun '10" within ".js_spend_quarters"
      And I should see "Jul '10 - Sep '10" within ".js_spend_quarters"

      # budget
      And I should not see "Apr '10 - Jun '10" within ".js_budget_quarters"
      And I should see "Jul '10 - Sep '10" within ".js_budget_quarters"
      And I should see "Oct '10 - Dec '10" within ".js_budget_quarters"
      And I should see "Jan '11 - Mar '11" within ".js_budget_quarters"
      And I should see "Apr '11 - Jun '11" within ".js_budget_quarters"
      And I should see "Jul '11 - Sep '11" within ".js_budget_quarters"


  Scenario: See FY quarters on other cost form for GOR FY
    Given now is "2010-07-15"
      And an organization exists with fiscal_year_start_date: "2010-07-01", fiscal_year_end_date: "2011-06-30"
      And a data_request exists
      And a data_response should exist with data_request: data_request
      And a project exists with data_response: the data_response
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And I am signed in as "reporter@hrtapp.com"
      And I follow "Projects"
      And I follow "Add Other Costs now"

    # spend
    Then I should not see "Apr '09 - Jun '09" within ".js_spend_quarters"
      And I should see "Jul '09 - Sep '09" within ".js_spend_quarters"
      And I should see "Oct '09 - Dec '09" within ".js_spend_quarters"
      And I should see "Jan '10 - Mar '10" within ".js_spend_quarters"
      And I should see "Apr '10 - Jun '10" within ".js_spend_quarters"
      And I should not see "Jul '10 - Sep '10" within ".js_spend_quarters"

      # budget
      And I should not see "Apr '10 - Jun '10" within ".js_budget_quarters"
      And I should see "Jul '10 - Sep '10" within ".js_budget_quarters"
      And I should see "Oct '10 - Dec '10" within ".js_budget_quarters"
      And I should see "Jan '11 - Mar '11" within ".js_budget_quarters"
      And I should see "Apr '11 - Jun '11" within ".js_budget_quarters"
      And I should not see "Jul '11 - Sep '11" within ".js_budget_quarters"


  Scenario: See FY quarters on other cost form for USG FY
    Given now is "2010-10-15"
      And an organization exists with fiscal_year_start_date: "2010-10-01", fiscal_year_end_date: "2011-09-30"
      And a data_request exists
      And a data_response should exist with data_request: data_request
      And a project exists with data_response: the data_response
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And I am signed in as "reporter@hrtapp.com"
      And I follow "Projects"
      And I follow "Add Other Costs now"

    # spend
    Then I should not see "Apr '09 - Jun '09" within ".js_spend_quarters"
      And I should see "Jul '09 - Sep '09" within ".js_spend_quarters"
      And I should see "Oct '09 - Dec '09" within ".js_spend_quarters"
      And I should see "Jan '10 - Mar '10" within ".js_spend_quarters"
      And I should see "Apr '10 - Jun '10" within ".js_spend_quarters"
      And I should see "Jul '10 - Sep '10" within ".js_spend_quarters"

      # budget
      And I should not see "Apr '10 - Jun '10" within ".js_budget_quarters"
      And I should see "Jul '10 - Sep '10" within ".js_budget_quarters"
      And I should see "Oct '10 - Dec '10" within ".js_budget_quarters"
      And I should see "Jan '11 - Mar '11" within ".js_budget_quarters"
      And I should see "Apr '11 - Jun '11" within ".js_budget_quarters"
      And I should see "Jul '11 - Sep '11" within ".js_budget_quarters"

