Feature: Admin can see reports
  In order to increase funding
  As an admin
  I want to be able to see reports

Scenario: Navigate to reports page
  Given I am signed in as an admin
  When I follow "Dashboard"
  And I follow "Reports" within the main nav
  Then I should see "Reports" within "h1"
