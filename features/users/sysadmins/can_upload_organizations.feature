Feature: Admin can manage organizations
  In order to save time
  As an admin
  I want to be able to upload organizations

  Background:
     Given an organization exists with name: "org1", raw_type: "Donor", fosaid: "111"
     And a data_request exists with title: "Req1", organization: the organization
     And an admin exists with email: "sysadmin@hrtapp.com", organization: the organization
     And I am signed in as "sysadmin@hrtapp.com"
     And I follow "Organizations"

  ### Can upload
  Scenario: Admin can upload organizations
    When I follow "Organizations"
    And I attach the file "spec/fixtures/organizations.csv" to "File"
    And I press "Upload and Import"
    Then I should see "Created 4 of 4 organizations successfully"
    And I should see "csv_org1"
    And I should see "csv_org2"
    And I should see "csv_org3"
    And I should see "csv_org4"

  Scenario: An admin can see error if no csv file is not attached for upload
    When I follow "Organizations"
    And I press "Upload and Import"
    Then I should see "Please select a file to upload"

  Scenario: An admin can see error when invalid csv file is attached for upload and download template
    When I follow "Organizations"
    And I attach the file "spec/fixtures/invalid.csv" to "File"
    And I press "Upload and Import"
    Then I should see "Wrong fields mapping. Please download the CSV template"
    When I follow "Download template"
    Then I should see "name,raw_type,fosaid"

  Scenario: Adding malformed CSV file doesnt throw exception
    When I follow "Organizations"
    And I attach the file "spec/fixtures/malformed.csv" to "File"
    And I press "Upload and Import"
    Then I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"
