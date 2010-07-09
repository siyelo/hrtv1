Feature: NGO can manage projects
  In order to ?
  As a NGO
  I want to be able to see projects

Scenario: "Navigate to projects page"
  Given I am on the ngo dashboard page
  When I follow "Workplan and Expenditures - due August 25"
  Then I should be on the projects listing page
  And I should see "Projects" within "h2"

#todo remove
Scenario: Single project is listed
  Given a project with name "Proj1"
  When I go to the projects listing page
  Then I should see "Proj1"
  
Scenario: All Projects are listed
  Given the following projects
    | name | description       | expected_total    |
    | P1   | p1 descr          | 20000 |
    | P2   | p2 descr          | 30000 |    
  When I go to the projects listing page
  Then I should see "P1"
  And I should see "P2"