Feature: Reporter can see help text
  In order to help reporters
  As a reporter
  I want to be able to see Comments/Questions and Help on the relevant pages

  Background:
    Given a basic org "UNDP" + reporter profile, with data response to "Req1", signed in


    Scenario: See help sidebar on Data Response page
      When I follow "Settings"
      Then I should see "What's a (Data) Response?"


    Scenario: See help sidebar on Projects page
      When I go to the new project page for response "Req1" org "UNDP"
      Then I should see "What's a Project?"
        And I should see "How do I add more detail?"
