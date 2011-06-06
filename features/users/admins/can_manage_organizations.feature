Feature: Admin can manage organizations
  In order to have good organizations in the system
  As an admin
  I want to be able to manage organizations

  Background:
    Given an organization exists with name: "org1", raw_type: "Donor", fosaid: "111"
      And a data_request exists with title: "Req1", organization: the organization
      And an organization exists with name: "org2", raw_type: "Ngo", fosaid: "222"
      And an admin exists with username: "admin", organization: the organization
      And a reporter exists with username: "org2_user", organization: the organization
      And a data_response exists with data_request: the data_request, organization: the organization
      And I am signed in as "admin"



    Scenario: Admin can CRUD organizations
      When I follow "Organizations"
        And I follow "Create Organization"
        And I fill in "Name" with "Organization name"
        And I fill in "Raw type" with "My raw_type"
        And I fill in "Fosaid" with "123"
        And I press "Create organization"
      Then I should see "Organization was successfully created"
        And I should see "Organization name"
        And I should see "My raw_type"
        And I should see "123"

      When I follow "Edit"
        And I fill in "Name" with "My new organization"
        And I press "Update organization"
      Then I should see "Organization was successfully updated"
        And I should see "My new organization"

      When I follow "X"
      Then I should see "Organization was successfully deleted"
        And I should not see "Organization name"


    Scenario Outline: Merge duplicate organizations
      When I follow "Organizations"
        And I follow "Fix duplicate organizations"
        And I select "<duplicate>" from "Duplicate organization"
        And I select "<target>" from "Replacement organization"
        And I press "Replace"
      Then I should see "<message>"

      Examples:
         | duplicate | target         | message                                               | 
         | org1      | org1 - 0 users | Same organizations for duplicate and target selected. | 
         | org1      | org2 - 2 users  | Organizations successfully merged.                    | 


    @javascript
    Scenario Outline: Merge duplicate organizations (with JS)
      When I follow "Organizations"
        And I follow "Fix duplicate organizations"
        And I select "<duplicate>" from "Duplicate organization"
        And I should see "Organization: <duplicate_box>" within "#duplicate"
        And I select "<target>" from "Replacement organization"
        And I should see "Organization: <target_box>" within "#target"
        And I confirm the popup dialog
        And I press "Replace"
      Then I should see "<message>"
        And the "Duplicate organization" text should be "<select_text>"

      Examples:
          | duplicate | target         | duplicate_box | target_box | message                                               | select_text | 
          | org1      | org1 - 0 users | org1          | org1       | Same organizations for duplicate and target selected. | org1        | 
          | org1      | org2 - 2 users  | org1          | org2       | Organizations successfully merged.                    |             | 


    @javascript
    Scenario Outline: Delete organization on merge duplicate organizations screen (with JS)
      When I follow "Organizations"
        And I follow "Fix duplicate organizations"
        And I select "<organization>" from "<select_type>"
        And I confirm the popup dialog
        And I follow "Delete" within "<info_block>"
      Then the "Duplicate organization" text should not be "<organization>"
        And the "Replacement organization" text should not be "<organization>"

        Examples:
         | organization   | select_type              | info_block                  | 
         | org1           | Duplicate organization   | .box[data-type='duplicate'] | 
         | org1 - 0 users | Replacement organization | .box[data-type='target']    | 


    @javascript
    Scenario: Try to delete non-empty organization (with JS)
      When I follow "Organizations"
        And I follow "Fix duplicate organizations"
        And I select "org2 - 2 users" from "Replacement organization"
        And I confirm the popup dialog
        And I follow "Delete" within ".box[data-type='target']"
      # Check that org2 organization is not deleted
      Then the "Replacement organization" text should match "org2 - 2 users"
        And I should see "You cannot delete an organization that has users or data associated with it."


    Scenario Outline: An admin can sort organizations
      When I follow "Organizations"
        And I follow "<column_name>"
      Then column "<column>" row "1" should have text "<text1>"
        And column "<column>" row "2" should have text "<text2>"

      When I follow "<column_name>"
      Then column "<column>" row "1" should have text "<text2>"
        And column "<column>" row "2" should have text "<text1>"

        Examples:
         | column_name | column | text1 | text2 | 
         | Name        | 1      | org2  | org1  | 
         | Raw Type    | 2      | Donor | Ngo   | 
         | Fosaid      | 3      | 111   | 222   | 


    Scenario: An admin can filter organization
      When I follow "Organizations"
      Then I should see "org1"
        And I should see "org2"
        And I fill in "query" with "org1"
        And I press "Search"
        And I should see "org1" within "table"
        And I should not see "org2" within "table"


    Scenario: Adding malformed CSV file doesn't throw exception
      When I follow "Organizations"
        And I attach the file "spec/fixtures/malformed.csv" to "File"
        And I press "Upload and Import"
      Then I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"


    Scenario: Reporter can upload activities
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
