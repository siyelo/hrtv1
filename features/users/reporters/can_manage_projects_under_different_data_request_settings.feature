Feature: Reporter can manage projects under specific data_request settings
  In order to track information
  As a reporter
  I want to be able to manage my projects

    Scenario: Reporter cannot see the quarterly budget fields if they are not available
      Given a data_request "data_request_no_quarters" exists with title: "data_request_no_quarters", budget_by_quarter: "false"
        And an organization "organization4" exists with name: "organization4"
        And a data_response "data_response3" should exist with data_request: data_request "data_request_no_quarters", organization: organization "organization4"
        And a project "Project9" exists with name: "Project9", data_response: data_response "data_response3"
        And a reporter exists with email: "reporter2@hrtapp.com", organization: organization "organization4", current_response: data_response "data_response3"
        And I am signed in as "reporter2@hrtapp.com"
        And I follow "Projects"
        And I follow "Project9"
      Then I should not see "Quarterly budget"


    Scenario: If the data_request spend is not checked, spend should not show up in the project screen
      Given an organization exists with name: "organization5"
        And a data_request exists with title: "data_request2", spend: false
        And a data_response should exist with data_request: the data_request, organization: the organization
        And a reporter exists with email: "reporter2@hrtapp.com", organization: the organization
        And a location exists with short_display: "Location1"
        And a location exists with short_display: "Location2"
        And I am signed in as "reporter2@hrtapp.com"
        And I follow "data_request2"
        And I follow "Projects"

      When I follow "Create Project"
      Then I should not see "Past Project Expenditure"
        And I should not see "Quarterly Spend"
        And I should see "Budget"

