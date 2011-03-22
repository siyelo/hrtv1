Feature: Admin can manage users
  In order to track information
  As an admin
  I want to be able to crete users

Background:
  Given an organization exists with name: "organization1"
  And an admin exists with username: "admin"
  And I am signed in as "admin"

Scenario: Admin can CRUD users
  When I follow "Users"
  And I follow "Create User"
  And I select "organization1" from "Organization"
  And I fill in "Username" with "pink.panter1"
  And I fill in "Email" with "pink.panter1@hrtapp.com"
  And I fill in "Full name" with "Pink Panter"
  And I select "Reporter" from "Roles"
  And I fill in "Password" with "password"
  And I fill in "Password confirmation" with "password"
  And I press "Create New User"
  Then I should see "User was successfully created"
  And I should see "pink.panter"

  When I follow "Edit"
  And I fill in "Username" with "pink.pangter2"
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
  When I follow "Create User"
  And I select "<organization>" from "Organization"
  And I fill in "Username" with "<username>"
  And I fill in "Email" with "<email>"
  And I fill in "Full name" with "<name>"
  And I select "<roles>" from "Roles"
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
  And an user exists with username: "user1", full_name: "User 1", full_name: "Full name 1", organization: the organization
  And an organization exists with name: "organization3"
  And an user exists with username: "user2", full_name: "User 2", full_name: "Full name 2", organization: the organization
  When I follow "Users"
  When I fill in "query" with "<query>"
  And I press "Search"
  Then I should see "<see>"
  And I should not see "<not_see>"
  Examples:
     | query         | see           | not_see       | 
     | user1         | user1         | user2         | 
     | user2         | user2         | user1         | 
     | User 1        | User 1        | User 2        | 
     | User 2        | User 2        | User 1        | 
     | Full name 1   | Full name 1   | Full name 2   | 
     | Full name 2   | Full name 2   | Full name 1   | 
     | organization1 | organization1 | organization2 | 
     | organization2 | organization2 | organization1 | 

