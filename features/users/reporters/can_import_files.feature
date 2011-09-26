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
    Then I should see "There was a problem with your file. Did you use the template provided and save the file as either XLS or CSV? Please post a problem at TenderApp if you can't figure out what's wrong."

  Scenario: Reporter cannot import and save without reviewing
    Then I should not see "Bulk Import"
    And I should not see "As the System Administrator, you can upload large files"
