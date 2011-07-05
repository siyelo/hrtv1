Feature: Reporter can manage data response
  In order to track information
  As a reporter
  I want to be able to manage data response

  Background:

    Scenario: User can start a data response
      Given a data_request exists with title: "Req1"
        And a basic org + reporter profile, signed in
      When I follow "Dashboard"
        And I follow "Respond"
      Then I should see "New Response" within "h1"

    Scenario: Browse to data response edit page
      Given a basic org + reporter profile, with data response, signed in
      When I follow "Settings"
      Then I should see "Your Response" within "h3"

    Scenario: Edit data response, see feedback messages
      Given a basic org + reporter profile, with data response, signed in
        And I follow "Settings"
        And I select "Euro (EUR)" from "data_response_currency"
        And I press "Update Response"
      Then I should see "Successfully updated settings"