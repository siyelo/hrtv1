Feature: Admin can manage users
  In order to track information
  As a sysadmin
  I want to be able to manage users

  Background:
    Given an organization exists with name: "organization1"
      And an organization exists with name: "FHI"
      And an sysadmin exists with email: "pink.panter@hrt.com"
      And I am signed in as "pink.panter@hrt.com"

      @javascript @run
    Scenario: Admin can add an user
      When I follow "Users" within the main nav
      Then I should see "Users" within the title
      And I fill in "theCombobox" with "FHI"
      When I fill in "Email" with "bob@siyelo.com"
      And I fill in "Full name" with "bob smith"
      And I select "Reporter" from "Role"
      And I press "Add user"
      Then I should see "An email invitation has been sent to 'bob smith' for the organization 'FHI'"
      And I should see "bob@siyelo.com" within "#js_organiations_tbl"
      And I should see "Pending" within "#js_organiations_tbl"

  Scenario: Admin can edit a user
    Given an organization exists with name: "organization22"
      And an user exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
    When I follow "Users"
      And I follow "Edit"
      And I fill in "Email" with "pink.panter2@hrtapp.com"
      And I press "Update User"
    Then I should see "User was successfully updated"
      And I should see "pink.panter2"
      And I should not see "pink.panter1"


  Scenario: Admin can delete a user
    Given an organization exists with name: "organization22"
      And an user exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
    When I follow "Users"
    Then show me the page
    When I follow "X" within "#js_organiations_tbl .odd"
    Then I should see "User was successfully destroyed"
      And I should not see "pink.panter1"



    @javascript
  Scenario Outline: Admin can CRUD users and see errors
    When I follow "Users" within the main nav
    And I fill in "theCombobox" with "<organization>"
    And I fill in "Email" with "<email>"
    And I fill in "Full name" with "<name>"
    And I select "<roles>" from "Role"
    And I press "Add user"
    Then I should see "<message>"

    Examples:
       | organization   | email         | name | roles    | message        |
       |                | pp@hrtapp.com | P    | Reporter | can't be blank |
       | organization1  |               | P    | Reporter | can't be blank |



  Scenario: Adding malformed CSV file doesn't throw exception
    When I follow "Users"
      And I attach the file "spec/fixtures/malformed.csv" to "File"
      And I press "Upload and Import"
    Then I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"


  Scenario: Admin can upload users
    When I follow "Users"
      And I attach the file "spec/fixtures/users.csv" to "File"
      And I press "Upload and Import"
    Then I should see "Created 4 of 4 users successfully"
      And I should see "user24"
      And I should see "user34"
      And I should see "user44"


  Scenario: Admin can see error if no csv file is not attached for upload
    When I follow "Users"
      And I press "Upload and Import"
    Then I should see "Please select a file to upload"

  Scenario: Admin can see error when invalid csv file is attached for upload and download template
    When I follow "Users"
      And I attach the file "spec/fixtures/invalid.csv" to "File"
      And I press "Upload and Import"
    Then I should see "Wrong fields mapping. Please download the CSV template"

    When I follow "Download template"
    Then I should see "organization_name,email,full_name,roles"

  Scenario Outline: a sysadmin can filter users
    Given an organization exists with name: "organization22"
      And an user exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
      And an organization exists with name: "organization33"
      And an user exists with email: "user2@hrtapp.com", full_name: "Full name 2", organization: the organization
    When I follow "Users"
      And I fill in "query" with "<first>"
      And I press "Search"
    Then I should see "Users with name, email or organiation name containing <first>"
    And I should see "<first>" within "#js_organiations_tbl"
    And I should not see "<second>" within "#js_organiations_tbl"
    And I fill in "query" with "<second>"

    When I press "Search"
    Then I should see "Users with name, email or organiation name containing <second>"
    And I should see "<second>" within "#js_organiations_tbl"
    And I should not see "<first>" within "#js_organiations_tbl"

    Examples:
       | first            | second           |
       | user1@hrtapp.com | user2@hrtapp.com |
       | user2@hrtapp.com | user1@hrtapp.com |
       | Full name 1      | Full name 2      |
       | Full name 2      | Full name 1      |
       | organization22    | organization33    |
       | organization33    | organization22    |

  Scenario Outline: a sysadmin can sort users
    Given an organization exists with name: "organization2"
      And a reporter exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
      And an organization exists with name: "organization3"
      And an activity_manager exists with email: "user2@hrtapp.com", full_name: "Full name 2", organization: the organization
    When I follow "Users"
      # filter out admin user
      And I fill in "query" with "user"
      And I press "Search"
      And I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text1>"
      And column "<column>" row "2" should have text "<text2>"

    When I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text2>"
      And column "<column>" row "2" should have text "<text1>"

      Examples:
          | column_name  | column | text1            | text2            |
          | Organization | 1      | organization2    | organization3    |
          | Full Name    | 2      | Full name 1      | Full name 2      |
          | Email        | 3      | user2@hrtapp.com | user1@hrtapp.com |


