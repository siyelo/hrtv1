Feature: Policy Maker can view review responses
  In order to view all my data
  As a NGO/Donor
  I want to be able to see review screen

Background:
  Given an organization exists with name: "GoR"
  And a data_request exists with title: "Req1", requesting_organization: the organization
  And an organization exists with name: "UNDP"
  And a reporter exists with username: "undp_user", organization: the organization
  And a data_response exists with data_request: the data_request, responding_organization: the organization
  And a project exists with name: "TB Treatment Project", data_response: the data_response
  And a comment exists with title: "title1", comment: "comment1", commentable: the project
  And an activity exists with name: "TB Drugs procurement", data_response: the data_response
  And the project is one of the activity's projects
  And an organization exists with name: "USAID"
  And a data_response exists with data_request: the data_request, responding_organization: the organization
  And a project exists with name: "Other Project", data_response: the data_response
  And a comment exists with title: "title2", comment: "comment2", commentable: the project

Scenario: "See list of all responses via admin dashboard"
  And I am signed in as an admin
  When I follow "Dashboard"
  And I follow "Review Organization Expenditures and Budgets"
  Then I should see "Data Responses" within "h1"

@wip
Scenario: "See policy maker dashboard"

# we need a separate policy maker dashboard
@wip
Scenario: "See list of all responses"
  And I am signed in as a policy maker
  When I follow "Dashboard"
  And I follow "Responses" within the main nav
  And I follow "Show"

