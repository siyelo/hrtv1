Feature: NGO can manage projects
  In order to ?
  As a NGO
  I want to be able to see projects

Background:
  Given a basic org + reporter profile, with data response, signed in

@green
Scenario: "Navigate to projects page"
  And I am on the reporter dashboard page
  And I follow "Edit"
  And I follow "Projects"
  Then I should be on the projects listing page
  And I should see "Projects" within "h2"
  
@green
Scenario: All Projects are listed
  Given the following projects
    | name | description       | budget  |
    | P1   | p1 descr          | 20000   |
    | P2   | p2 descr          | 30000   | 
  When I go to the projects listing page
  Then I should see "P1"
  And I should see "P2"
