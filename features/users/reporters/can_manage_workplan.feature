Feature: Reporter can see workplan
  In order to review all my entered data
  As a reporter
  I want to be able to see my workplan

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "project1", data_response: the data_response
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And an activity exists with id: "1", name: "activity1", description: "activity1 description", data_response: the data_response, project: the project, budget: 100, spend: 200
      And I am signed in as "reporter@hrtapp.com"
      And I follow "Projects"

	@run 
	Scenario: Reporter can upload activities and projects
		Given I follow "import_export"
		When  I attach the file "spec/fixtures/projects.csv" to "File"
		And   I press "Import" within ".upload_box"
		Then  I should see "Successfully imported 2 of 2 projects and created/updated 5 of 5 activities"

	Scenario: Reporter can see error if no csv file is not attached for upload
		When I press "Import" within ".activities_upload_box"
		Then I should see "Please select a file to upload"

	Scenario: Adding malformed CSV file doesn't throw exception
		Given I follow "import_export"
		When  I attach the file "spec/fixtures/malformed.csv" to "File"
		And   I press "Import"
		Then  I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"

	Scenario: Reporter can download Activities CSV template
		When I follow "Get Template" within ".activities_upload_box"
		Then I should see "project_name,project_description,activity_name,activity_description,spend,budget"

	Scenario: Reporter can download Activities
		Given an activity exists with project: the project, name: "Activity1", description: "Activity1 description", data_response: the data_response
		When I follow "Projects"
		And  I follow "Export" within ".upload_box"
		Then I should see "Activity1"
		And  I should see "Activity1 description"
