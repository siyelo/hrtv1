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
  And an activity exists with name: "Activity", data_response: the data_response
  And the project is one of the activity's projects
  And I am signed in as "reporter"
  When I go to the activities page
  And I follow "Classify"
  Then I should see "Activity"
  And I should see "Coding" within the budget coding tab
  And I should see "District" within the budget districts tab
  And I should see "Categorization" within the budget cost categorization tab
  And I should see "Coding" within the expenditure coding tab
  And I should see "District" within the expenditure districts tab
  And I should see "Cost Categorization" within the expenditure cost categorization tab

Scenario: See all tabs when data request is for budget but not spend
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request", budget: true, spend: false
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "Activity", data_response: the data_response
  And the project is one of the activity's projects
  And I am signed in as "reporter"
  When I go to the activities page
  And I follow "Classify"
  Then I should see "Activity"
  And I should see "Coding" within the budget coding tab
  And I should see "District" within the budget districts tab
  And I should see "Categorization" within the budget cost categorization tab
  And page should have css "#tab1"
  And page should have css "#tab2"
  And page should have css "#tab3"
  And page should not have css "#tab4"
  And page should not have css "#tab5"
  And page should not have css "#tab6"

Scenario: See all tabs when data request is for spend but not budget
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request", budget: false, spend: true
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "Activity", data_response: the data_response
  And the project is one of the activity's projects
  And I am signed in as "reporter"
  When I go to the activities page
  And I follow "Classify"
  Then I should see "Activity"
  And I should see "Coding" within the expenditure coding tab
  And I should see "District" within the expenditure districts tab
  And I should see "Cost Categorization" within the expenditure cost categorization tab
  And page should not have css "#tab1"
  And page should not have css "#tab2"
  And page should not have css "#tab3"
  And page should have css "#tab4"
  And page should have css "#tab5"
  And page should have css "#tab6"
