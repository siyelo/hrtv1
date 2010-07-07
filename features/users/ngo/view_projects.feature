Feature: NGO can manage projects
  In order to ?
  As a NGO
  I want to be able to see projects

Scenario: "Navigate to projects page"
  Given I am on the ngo dashboard page
  When I follow "Workplan and Expenditures - due August 25"
  Then I should be on the projects listing page
  And I should see "Projects" within "h2"

