Feature: Reporter can see comments & help for a data response 
  In order to help reporters
  As a reporter
  I want to be able to see Comments/Questions and Help on the relevant pages

Scenario Outline: See comments/help
  Given I am signed in as a reporter
  When I go to the <page> page
  Then I should see "General Questions / Comments"
  And I should see "Help"
  And I should see "Field Definitions"
  Examples:
    | page | 
    | projects |
    | funding sources |
    | providers |
    | activities |
    | other costs |

Scenario Outline: See comments/help for an activity breakdown(/classification)
  Given a project with name "TB Treatment Project"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" 
  Given I am signed in as a reporter
  When I go to the <page> page for "TB Drugs procurement"
  Then I should see "General Questions / Comments"
  And I should see "Help"
  And I should see "Field Definitions"
  Examples:
     | page |
     | budget classification |
     | expenditure classification |
