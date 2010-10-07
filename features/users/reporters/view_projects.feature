Feature: NGO can manage projects
  In order to ?
  As a NGO
  I want to be able to see projects

@wip
Scenario: "Navigate to projects page"
  Given I am signed in as a reporter 
  Given I am on the reporter dashboard page
  When I follow "Workplan and Expenditures - due August 25"
  Then I should be on the projects listing page
  And I should see "Projects" within "h2"

@wip
Scenario: Single project is listed
  Given I am signed in as a reporter 
  Given a project with name "Proj1"
  When I go to the projects listing page
  Then show me the page
  Then I should see "Proj1"
  
@wip
Scenario: All Projects are listed
  Given the following projects
    | name | description       | budget  |
    | P1   | p1 descr          | 20000   |
    | P2   | p2 descr          | 30000   | 
  Given I am signed in as a reporter    
  When I go to the projects listing page
  Then I should see "P1"
  And I should see "P2"
