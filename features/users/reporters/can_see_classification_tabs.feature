@run
Feature: Reporter can see classification tabs
  In order to enter data
  As a reporter
  I want to be able to see classification tabs

Scenario: See budget and spend tabs when data request is for budget and spend
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request", budget: true, spend: true
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "activity1", data_response: the data_response, project: the project, description: "activity1 description"
  And I am signed in as "reporter"
  And I follow "Request"
  And I follow "Projects"
  And I follow "activity1 description"
  Then I should see "Spend" within ".inline_tab"
  And I should see "Budget" within ".inline_tab"

Scenario: See only budget tab when data request is for budget but not spend
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request", budget: true, spend: false
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "activity1", data_response: the data_response, project: the project, description: "activity1 description"
  And I am signed in as "reporter"
  And I follow "Request"
  And I follow "Projects"
  And I follow "activity1 description"
  Then I should see "Budget" within ".inline_tab"
  And I should not see "Spend" within ".inline_tab"

Scenario: See spend tab when data request is for spend but not budget
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request", budget: false, spend: true
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "activity1", data_response: the data_response, project: the project, description: "activity1 description"
  And I am signed in as "reporter"
  And I follow "Request"
  And I follow "Projects"
  And I follow "activity1 description"
  Then I should see "Spend" within ".inline_tab"
  And I should not see "Budget" within ".inline_tab"
