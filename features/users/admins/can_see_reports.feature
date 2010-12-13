Feature: See Reports
  In order to increase funding
  As an admin
  I want to be able to see reports

# Background:
#   Given an organization exists with name: "UNAIDS"
#   And a data_request exists with title: "Req1", requesting_organization: the organization
#   And an organization exists with name: "WHO"
#   And a reporter exists with username: "who_user", organization: the organization
#   And a data_response exists with data_request: the data_request, responding_organization: the organization
  
@admin
Scenario Outline: Navigate to reports page
  Given I am signed in as an admin
  When I follow "Dashboard"
  And I follow "Reports" within the main nav
  Then I should see "Reports" within "h1"
  
  
