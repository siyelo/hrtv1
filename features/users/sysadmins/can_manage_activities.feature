Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

  Background:
    Given an organization exists with name: "organization1"
      And an user exists with email: "email@siyelo.com", roles: "admin", organization: the organization
      And a data_request exists with title: "data_request1"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "project1", data_response: the data_response
      And an activity exists with name: "activity1", description: "activity1 description", project: the project, data_response: the data_response, spend: 1, budget: 1
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a project exists with name: "project2", data_response: the data_response
      And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response, spend: 2, budget: 2
      And a sysadmin exists with email: "admin@hrtapp.com"
      And I am signed in as "admin@hrtapp.com"
      When I follow "Organizations"
      And I follow "organization1"
      Then I should see "activity1"
      When I follow "activity1"

  Scenario: a sysadmin can review activities
    And I follow "Delete this Activity"
    Then I should not see "activity1"

    Scenario: a sysadmin can edit activity
      And I fill in "Name" with "activity2"
      And I fill in "Description" with "activity2 description"
      And I press "Save"
    Then I should see "activity2"
      And I should not see "activity1"

	@run
  Scenario: a sysadmin can create comments for an activity
      And I fill in "Title" with "Comment title"
      And I fill in "Comment" with "Comment body"
      And I press "comment_submit"
    Then I should see "Comment title"
      And I should see "Comment body"
      And I should see "activity1"

	@run
  Scenario: a sysadmin can create comments for an activity and see comment errors
      And I press "comment_submit"
      Then I should see "You cannot create blank comment."
      When I fill in "Comment" with "Comment body"
      And I fill in "Title" with "Comment Title"
        And I press "Create Comment"
      Then I should see "Comment body"
      And I should see "Comment Title"

	@run
  Scenario: Sends email to users when a comment is made by a sysadmin
    Given no emails have been sent
      And I fill in "Title" with "Comment title"
      And I fill in "Comment" with "Comment body"
      And I press "Create Comment"
      And "email@siyelo.com" should receive an email
      And I open the email
    Then I should see "Comment body" in the email body