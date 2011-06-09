Feature: Admin can manage users
  In order to track information
  As an admin
  I want to be able to manage users

  Background:
    Given an organization exists with name: "organization1"
      And an organization exists with name: "FHI"
      And an admin exists with email: "pink.panter@hrt.com"
      And I am signed in as "pink.panter@hrt.com"

      @run @javascript
    Scenario: Add a user
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

      @wip
    Scenario: Admin can CRUD users
      When I follow "Users"
      Then I should see the "Users" tab is "active"
        And I follow "Create User"
        And I select "organization1" from "Organization"
        And I fill in "Email" with "pink.panter1@hrtapp.com"
        And I fill in "Full name" with "Pink Panter"
        And I select "Reporter" from "Role"
        And I fill in "Password" with "password"
        And I fill in "Password confirmation" with "password"
        And I press "Create New User"
      Then I should see "User was successfully created"
        And I should see "pink.panter"

      When I follow "Edit"
        And I fill in "Email" with "pink.panter2@hrtapp.com"
        And I press "Update User"
      Then I should see "User was successfully updated"
        And I should see "pink.panter2"
        And I should not see "pink.panter1"

      When I follow "X"
      Then I should see "User was successfully destroyed"
        And I should not see "pink.panter1"
        And I should not see "pink.panter2"


    Scenario Outline: Admin can CRUD users and see errors
      When I follow "Users"
        And I follow "Create User"
        And I select "<organization>" from "Organization"
        And I fill in "Username" with "<username>"
        And I fill in "Email" with "<email>"
        And I fill in "Full name" with "<name>"
        And I select "<roles>" from "Role"
        And I fill in "Password" with "<password>"
        And I fill in "Password confirmation" with "<password_conf>"
        And I press "Create New User"
      Then I should see "Oops, we couldn't save your changes."
        And I should see "<message>"

        Examples:
           | organization  | username | email         | name | roles    | password | password_conf | message                     |
           |               | panter   | pp@hrtapp.com | P    | Reporter | password | password      | Organization can't be blank |
           | organization1 |          | pp@hrtapp.com | P    | Reporter | password | password      | Username can't be blank     |
           | organization1 | panter   |               | P    | Reporter | password | password      | Email can't be blank        |


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
        And I should see "user1"
        And I should see "user2"
        And I should see "user3"
        And I should see "user4"


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
      Then I should see "organization_name,username,email,full_name,roles,password,password_confirmation"


    Scenario Outline: An admin can filter users
      Given an organization exists with name: "organization2"
        And an user exists with username: "user1", email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
        And an organization exists with name: "organization3"
        And an user exists with username: "user2", email: "user2@hrtapp.com", full_name: "Full name 2", organization: the organization
      When I follow "Users"
        And I fill in "query" with "<first>"
        And I press "Search"
      Then I should see "Users with username, name, email or organiation name containing <first>"
      And I should see "<first>"
      And I should not see "<second>"
      And I fill in "query" with "<second>"

      When I press "Search"
      Then I should see "Users with username, name, email or organiation name containing <second>"
      And I should see "<second>"
      And I should not see "<first>"

      Examples:
         | first            | second           |
         | user1            | user2            |
         | user2            | user1            |
         | user1@hrtapp.com | user2@hrtapp.com |
         | user2@hrtapp.com | user1@hrtapp.com |
         | Full name 1      | Full name 2      |
         | Full name 2      | Full name 1      |
         | organization1    | organization2    |
         | organization2    | organization1    |


    Scenario Outline: An admin can sort users
      Given an organization exists with name: "organization2"
        And a reporter exists with username: "user1", email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
        And an organization exists with name: "organization3"
        And an activity_manager exists with username: "user2", email: "user2@hrtapp.com", full_name: "Full name 2", organization: the organization
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
            | Username     | 1      | user2            | user1            |
            | Email        | 2      | user1@hrtapp.com | user2@hrtapp.com |
            | Full Name    | 3      | Full name 1      | Full name 2      |
            | Organization | 4      | organization2    | organization3    |
