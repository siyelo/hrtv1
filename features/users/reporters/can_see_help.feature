Feature: Reporter can see help text
  In order to help reporters
  As a reporter
  I want to be able to see Comments/Questions and Help on the relevant pages

  Background:
    Given a basic org "UNDP" + reporter profile, with data response to "Req1", signed in


    
    # this spec is for CMS-style help - to be added back once the UI is stabilised. 
    @wip
    Scenario Outline: See help sections from the CMS 
      Given model help for "<page>" page
      When I go to the <page> page
      Then I should see "Questions on this Page"
        And I should see "Help"
        And I should see "Field Definitions"

        Examples:
          | page             |
          | projects         |
          | funding sources  |
          | implementers     |
          | activities       |
          | classifications  |
          | other costs      |


    Scenario: See help sidebar on Data Response page
      When I go to the data response page for "Req1"
      Then I should see "What's a (Data) Response?"


    Scenario: See help sidebar on Projects page
      When I go to the new project page for response "Req1" org "UNDP"
      Then I should see "What's a Project?"
        And I should see "How do I add more detail?"
