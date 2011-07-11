Feature: Reporter can see dashboard
  In order to see latest news
  As a reporter
  I want to be able to see a dashboard for relevant activities

  Background:
      
    Scenario: "See data requests"
		  Given a basic org + reporter profile, with data response, signed in
      When I go to the reporter dashboard page
      Then I should see "Dashboard"
        And I should see "Data Requests & Responses"

    Scenario: See menu tabs when a Data Req is selected
      Given a basic org + reporter profile, with data response, signed in
      When I go to the reporter dashboard page
        And I follow "Req1"
      Then I should see "Home" within the main nav
        And I should see "Workplan" within the main nav
        And I should see "Settings" within the main nav
        And I should see "Reports" within the main nav


    Scenario: See unfulfilled/current Data Requests listed
      Given an organization exists with name: "WHO"
        And a data_request exists with title: "Req2", organization: the organization
        And a data_request exists with title: "Req1", organization: the organization
        And a reporter exists with email: "some_user@hrtapp.com", organization: the organization
        And a data_response exists with data_request: the data_request, organization: the organization
        And I am signed in as "some_user@hrtapp.com"
      When I go to the reporter dashboard page
      Then I should see "Req1" within "#content"
        And I should see "Req2" within "#content"
