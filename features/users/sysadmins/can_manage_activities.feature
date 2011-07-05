Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

  Background:
    Given an organization exists with name: "organization1"
      And an user exists with email: "email@siyelo.com", roles: "admin", organization: the organization
      And a data_request exists with title: "data_request1"
      And a data_response exists with data_request: the data_request, organization: the organization
      And a project exists with name: "project1", data_response: the data_response
      And an activity exists with name: "activity1", description: "activity1 description", project: the project, data_response: the data_response, spend: 1, budget: 1
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a project exists with name: "project2", data_response: the data_response
      And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response, spend: 2, budget: 2
      And a sysadmin exists with email: "admin@hrtapp.com"
      And I am signed in as "admin@hrtapp.com"

    Scenario: a sysadmin can review activities
      When I follow "Activities"
        And I follow "activity1 description"
      Then I should see "activity1"
        And I should see "activity1 description"

      When I follow "X"
      Then I should not see "activity1 description"

      Scenario: a sysadmin can edit activity
      When I follow "Activities"
        And I follow "Edit"
        And I fill in "Description" with "activity2 description"
        And I press "Update"
      Then I should see "activity2 description"
        And I should not see "activity1 description"


    Scenario: a sysadmin can create comments for an activity
      When I follow "Activities"
        And I follow "activity1 description"
        And I fill in "Title" with "Comment title"
        And I fill in "Comment" with "Comment body"
        And I press "Create Comment"
      Then I should see "Comment title"
        And I should see "Comment body"
        And I should see "activity1 description"


    Scenario: a sysadmin can create comments for an activity and see comment errors
      When I follow "Activities"
        And I follow "activity1 description"
        And I press "Create Comment"
      Then I should see "can't be blank" within "#comment_title_input"
        And I should see "can't be blank" within "#comment_comment_input"

      When I fill in "Title" with "Comment title"
        And I press "Create Comment"
      Then I should not see "can't be blank" within "#comment_title_input"
        And I should see "can't be blank" within "#comment_comment_input"

      When I fill in "Comment" with "Comment body"
        And I press "Create Comment"
      Then I should see "Comment title"
        And I should see "Comment body"
        And I should see "activity1 description"


    Scenario: a sysadmin can filter activities
      When I follow "Activities"
      Then I should see "activity1 description"
        And I should see "activity2 description"
        And I fill in "query" with "activity1"
        And I press "Search"
        And I should see "activity1 description"
        And I should not see "activity2 description"


    Scenario: Sends email to users when a comment is made by a sysadmin
      Given no emails have been sent
      When I follow "Activities"
        And I follow "activity1 description"
        And I fill in "Title" with "Comment title"
        And I fill in "Comment" with "Comment body"
        And I press "Create Comment"
        And "email@siyelo.com" should receive an email
        And I open the email
      Then I should see "Comment body" in the email body


    Scenario Outline: a sysadmin can sort activities
      Given I follow "Activities"
      When I follow "<column_name>"
      Then column "<column>" row "1" should have text "<text1>"
        And column "<column>" row "2" should have text "<text2>"

      When I follow "<column_name>"
      Then column "<column>" row "1" should have text "<text2>"
        And column "<column>" row "2" should have text "<text1>"

        Examples:
          | column_name  | column | text1                 | text2                 |
          | Project      | 1      | project1              | project2              |
          | Description  | 2      | activity1 description | activity2 description |
          | Total Past Expenditure  | 3      | 1 RWF               | 2 RWF               |
          | Total Budget | 4      | 1 RWF               | 2 RWF               |
