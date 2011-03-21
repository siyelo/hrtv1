Feature: Reporter can see classification tabs
  In order to enter data
  As a reporter
  I want to be able to see classification tabs

Scenario: See all tabs when data request is for budget and spend
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request", budget: true, spend: true
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "Activity", data_response: the data_response, project: the project
  And I am signed in as "reporter"
  And I follow "Request"
  And I follow "Activities"
  And I follow "Classify"
  Then I should see "Activity"
  And I should see "Purposes" within the budget coding tab
  And I should see "Locations" within the budget districts tab
  And I should see "Inputs" within the budget cost categorization tab
  And I should see "Purposes" within the expenditure coding tab
  And I should see "Locations" within the expenditure districts tab
  And I should see "Inputs" within the expenditure cost categorization tab

Scenario: See all tabs when data request is for budget but not spend
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request", budget: true, spend: false
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "Activity", data_response: the data_response, project: the project
  And I am signed in as "reporter"
  And I follow "Request"
  And I follow "Activities"
  And I follow "Classify"
  Then I should see "Activity"
  And I should see "Purposes" within the budget coding tab
  And I should see "Locations" within the budget districts tab
  And I should see "Inputs" within the budget cost categorization tab
  And I should see "Service Levels" within the budget service levels tab
  And page should have css "#tab1"
  And page should have css "#tab2"
  And page should have css "#tab3"
  And page should have css "#tab4"
  And page should not have css "#tab5"
  And page should not have css "#tab6"
  And page should not have css "#tab7"
  And page should not have css "#tab8"

Scenario: See all tabs when data request is for spend but not budget
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request", budget: false, spend: true
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "Activity", data_response: the data_response, project: the project
  And I am signed in as "reporter"
  And I follow "Request"
  And I follow "Activities"
  And I follow "Classify"
  Then I should see "Activity"
  And I should see "Purposes" within the expenditure coding tab
  And I should see "Locations" within the expenditure districts tab
  And I should see "Inputs" within the expenditure cost categorization tab
  And page should not have css "#tab1"
  And page should not have css "#tab2"
  And page should not have css "#tab3"
  And page should not have css "#tab4"
  And page should have css "#tab5"
  And page should have css "#tab6"
  And page should have css "#tab7"
  And page should have css "#tab8"
