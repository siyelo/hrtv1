Feature: Admin can manage users
  In order to track information
  As a sysadmin
  I want to be able to manage users

  Background:
  
    Given an organization exists with name: "MoH"
      And a data_request exists with title: "Req1", organization: the organization
      And a sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
      And I am signed in as "sysadmin@hrtapp.com"
		#requires javascript but filling in autocomplete is not working
  
    @javascript @wip
    Scenario: Admin can add an user
      When I follow "Members" within the main nav
      Then I should see "Members" within the title
        # And I select "Reporter" from "member_roles"
				And I select "organization1" from "member_organization_id"
	      #And I fill in "theCombobox" with "FHI"
				#Then I click "FHI" in autocomplete results
				Then wait a few moments
	      And I fill in "Email" with "bob@siyelo.com"
	      And I fill in "Full name" with "bob smith"
	      And I press "Add user"
      Then I should see "An email invitation has been sent to 'bob smith' for the organization 'FHI'" within ".js_message"
      And I should see "bob@siyelo.com" within "#js_organiations_tbl"
      And I should see "Pending" within "#js_organiations_tbl"
      And "bob@siyelo.com" should receive an email

  Scenario: Admin can edit a user
    Given an organization exists with name: "organization22"
      And an user exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
    When I follow "Members"
      And I follow "Edit"
      And I fill in "Email" with "pink.panter2@hrtapp.com"
      And I press "Update Member"
    Then I should see "User was successfully updated"
      And I should see "pink.panter2"
      And I should not see "pink.panter1"
  
  
  Scenario: Admin can delete a user
    Given an organization exists with name: "organization22"
      And an user exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
    When I follow "Members"
    When I follow "X" within "#js_organiations_tbl .odd"
    Then I should see "User was successfully destroyed"
      And I should not see "pink.panter1"
  
  
  Scenario Outline: Admin can CRUD users and see errors
    When I follow "Members"
      And I select "<organization>" from "Organization"
      And I fill in "Email" with "<email>"
      And I fill in "Full name" with "<name>"
      And I select "<roles>" from "Role"
      And I press "Add"
      And I should see "<message>"

      Examples:
         | organization  | email         | name | roles    |message                     |
         |               | pp@hrtapp.com | P    | Reporter | Oops, we couldn't add that member.  |
         | MoH |               | P    | Reporter | Oops, we couldn't add that member.  |
  
  
  
  Scenario: Adding malformed CSV file doesn't throw exception
    When I follow "Members"
      And I attach the file "spec/fixtures/malformed.csv" to "File"
      And I press "Upload and Import"
    Then I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"
  
  
  Scenario: Admin can upload users
    When I follow "Members"
      And I attach the file "spec/fixtures/users.csv" to "File"
      And I press "Upload and Import"
    Then I should see "Created 4 of 4 users successfully"
      And I should see "user24"
      And I should see "user34"
      And I should see "user44"
  
  
  Scenario: Admin can see error if no csv file is not attached for upload
    When I follow "Members"
      And I press "Upload and Import"
    Then I should see "Please select a file to upload"
  
  Scenario: Admin can see error when invalid csv file is attached for upload and download template
    When I follow "Members"
      And I attach the file "spec/fixtures/invalid.csv" to "File"
      And I press "Upload and Import"
    Then I should see "Wrong fields mapping. Please download the CSV template"
  
    When I follow "Download template"
    Then I should see "organization_name,email,full_name,roles"
  
  
  Scenario Outline: An admin can filter users
    Given an organization exists with name: "organization2"
      And an user exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
      And an organization exists with name: "organization3"
      And an user exists with email: "user2@hrtapp.com", full_name: "Full name 2", organization: the organization
    When I follow "Members"
      And I fill in "query" with "<first>"
      And I press "Search"
    Then I should see "Members found containing <first>"
      And I should see "<first>"
      And I should not see "<second>"
    
    Examples:
       | first            | second           |
       | user1            | user2            |
       | user2            | user1            |
       | user1@hrtapp.com | user2@hrtapp.com |
       | user2@hrtapp.com | user1@hrtapp.com |
       | Full name 1      | Full name 2      |
       | Full name 2      | Full name 1      |
       | organization2    | Full name 2    |
       | organization3    | Full name 1    |
       
       
  Scenario Outline: a sysadmin can sort users
    Given an organization exists with name: "organization2"
      And a reporter exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
      And an organization exists with name: "organization3"
      And an activity_manager exists with email: "user2@hrtapp.com", full_name: "Full name 2", organization: the organization
    When I follow "Members"
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
          | Organization | 3      | organization2    | organization3    |
          | Full Name    | 1      | Full name 1      | Full name 2      |
          | Email        | 2      | user2@hrtapp.com | user1@hrtapp.com |


