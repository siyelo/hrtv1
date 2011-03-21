Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

Background:
  Given an organization exists with name: "organization1"
  And a data_request exists with title: "data_request1"
  And an organization exists with name: "organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization
  And a project exists with name: "project1", data_response: the data_response
  And an activity exists with name: "activity1", description: "activity1 description", project: the project, data_response: the data_response, spend: 1, budget: 1
  And a project exists with name: "project2", data_response: the data_response
  And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response, spend: 2, budget: 2
  And an admin exists with username: "admin"
  And I am signed in as "admin"

Scenario: An admin can review activities
  When I follow "Activities"
  And I follow "activity1 description"
  Then I should see "activity1"
  And I should see "activity1 description"
  When I follow "X"
  Then I should not see "activity1 description"

Scenario: An admin can create comments for an activity
  When I follow "Activities"
  And I follow "activity1 description"
  And I fill in "Title" with "Comment title"
  And I fill in "Comment" with "Comment body"
  And I press "Create Comment"
  Then I should see "Comment title"
  And I should see "Comment body"
  And I should see "activity1 description"

Scenario: An admin can create comments for an activity and see comment errors
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

Scenario: An admin can filter activities
  When I follow "Activities"
  Then I should see "activity1 description"
  And I should see "activity2 description"
  And I fill in "query" with "activity1"
  And I press "Search"
  Then I should see "activity1 description"
  And I should not see "activity2 description"

Scenario Outline: An admin can sort activities
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
      | Total Spent  | 3      | 1.0 RWF               | 2.0 RWF               | 
      | Total Budget | 4      | 1.0 RWF               | 2.0 RWF               | 
