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
  And an activity exists with name: "activity1", description: "activity1 description", project: the project, data_response: the data_response
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
  Given an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response
  When I follow "Activities"
  Then I should see "activity1 description"
  And I should see "activity2 description"
  And I fill in "query" with "activity1"
  And I press "Search"
  Then I should see "activity1 description"
  And I should not see "activity2 description"
