Feature: Admin can manage codes
  In order to track information
  As a sysadmin
  I want to be able to manage codes

  Background:
    Given an organization exists with name: "organization1"
      And a sysadmin exists with username: "admin"
      And I am signed in as "admin"



    Scenario: Admin can CRUD codes
      When I follow "Codes"
        And I follow "Create Code"
        And I fill in "Short display" with "code1"
        And I select "Mtef" from "Type"
        And I fill in "Long display" with "code1 long"
        And I fill in "Official name" with "code1 official name"
        And I fill in "Description" with "code1 description"
        And I press "Create New Code"
      Then I should see "Code was successfully created"
        And I should see "code1"
        And I should see "code1 long"
        And I should see "code1 official name"
        And I should see "code1 description"

      When I follow "Edit"
        And I fill in "Short display" with "code2"
        And I fill in "Long display" with "code2 long"
        And I fill in "Official name" with "code2 official name"
        And I fill in "Description" with "code2 description"
        And I press "Update Code"
      Then I should see "Code was successfully updated"
        And I should see "code2"
        And I should not see "code1"

      When I follow "X"
      Then I should see "Code was successfully destroyed"
        And I should not see "code1"
        And I should not see "code2"


    Scenario: Adding malformed CSV file doesn't throw exception
      When I follow "Codes"
        And I attach the file "spec/fixtures/malformed.csv" to "File"
        And I press "Upload and Import"
      Then I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"


    Scenario: Admin can upload codes
      When I follow "Codes"
        And I attach the file "spec/fixtures/codes.csv" to "File"
        And I press "Upload and Import"
      Then I should see "Created 4 of 4 codes successfully"
        And I should see "code1"
        And I should see "code2"
        And I should see "code3"
        And I should see "code4"


    Scenario: Admin can see error if no csv file is not attached for upload
      When I follow "Codes"
        And I press "Upload and Import"
      Then I should see "Please select a file to upload"


    Scenario: Admin can see error when invalid csv file is attached for upload and download template
      When I follow "Codes"
        And I attach the file "spec/fixtures/invalid.csv" to "File"
        And I press "Upload and Import"
      Then I should see "Wrong fields mapping. Please download the CSV template"

      When I follow "Download template"
      Then I should see "short_display,long_display,description,type,external_id,parent_short_display,hssp2_stratprog_val,hssp2_stratobj_val,official_name,sub_account,nha_code,nasa_code"


    Scenario Outline: a sysadmin can filter codes
      Given a mtef_code exists with short_display: "code1", description: "code1 desc"
        And a nha_code exists with short_display: "code2", description: "code2 desc"

      When I follow "Codes"
        And I fill in "query" with "<first>"
        And I press "Search"
      Then I should see "Codes with short_display, type or description containing <first>"
        And I should see "<first>"
        And I should not see "<second>"
        And I fill in "query" with "<second>"
        And I press "Search"
        And I should see "Codes with short_display, type or description containing <second>"
        And I should see "<second>"
        And I should not see "<first>"

        Examples:
            | first      | second     | 
            | user1      | user2      | 
            | user2      | user1      | 
            | user1 desc | user2 desc | 
            | user2 desc | user1 desc | 
            | Nha        | Mtef       | 
            | Mtef       | Nha        | 


    Scenario Outline: a sysadmin can sort codes
      Given a mtef_code exists with short_display: "code1", description: "code1 desc"
        And a nha_code exists with short_display: "code2", description: "code2 desc"
      When I follow "Codes"
        And I follow "<column_name>"
      Then column "<column>" row "1" should have text "<text1>"
        And column "<column>" row "2" should have text "<text2>"

      When I follow "<column_name>"
      Then column "<column>" row "1" should have text "<text2>"
        And column "<column>" row "2" should have text "<text1>"

        Examples:
           | column_name   | column | text1      | text2      | 
           | Short Display | 1      | code2      | code1      | 
           | Type          | 2      | Mtef       | Nha        | 
           | Description   | 3      | code1 desc | code2 desc | 
