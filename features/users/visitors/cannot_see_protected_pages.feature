Feature: Visitors cannot see protected pages
  In order to protect information
  As a visitor
  I should not be able to see certain pages  

@allow-rescue
@green
Scenario Outline: Visit protected page, get redirected to login screen
  When I go to the <page> page
  Then I should see "You are not authorized to do that"
  And I should be on the login page 
  Examples:
    | page            |
    | projects        |
    | funding sources |
    | implementers    |
    | activities      |
    | classifications |
    | other costs     |