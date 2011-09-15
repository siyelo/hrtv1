Feature: Reporter can import/export workplans
  In order to speed up data entry
  As a reporter
  I want to be able to import/export

  Background:
    Given an organization exists with name: "organization1"
    And a data_request exists with title: "data_request1"
    And an organization "my_organization" exists with name: "organization2"
    Then data_response should exist with data_request: the data_request, organization: the organization
    And a reporter exists with email: "reporter@hrtapp.com", organization: organization "my_organization"
    And a project exists with name: "project1", data_response: the data_response
    And I am signed in as "reporter@hrtapp.com"
    And I go to the set request page for "data_request1"
    And I follow "Projects"

  Scenario: Reporter can upload activities
    When I attach the file "spec/fixtures/activities.csv" to "File" within ".activities_upload_box"
    And I press "Import" within ".activities_upload_box"
    Then I should see "Import: Review & Save"

  Scenario: Reporter can see error if no csv file is not attached for upload
    When I press "Import" within ".activities_upload_box"
    Then I should see "Please select a file to upload"

  Scenario: Adding malformed CSV file doesnt throw exception
    When I attach the file "spec/fixtures/malformed.csv" to "File" within ".activities_upload_box"
    And I press "Import" within ".activities_upload_box"
    Then I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"

  Scenario: Reporter can download Activities
    Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
    When I follow "Projects"
    And I follow "Export" within ".activities_upload_box"
    Then I should see "Activity1"
    And I should see "Activity1 description"
