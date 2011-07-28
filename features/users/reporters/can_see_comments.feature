Feature: Reporter can see comments
  In order to help reporters see missed areas
  As a reporter
  I want to be able to see comments that reviewers have made

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a project exists with name: "TB Treatment Project", data_response: the data_response
      And an activity exists with name: "TB Activity", project: the project, data_response: the data_response
      And a comment exists with title: "title1", comment: "comment1", commentable: the project, user: the reporter
	  And I am signed in as "reporter@hrtapp.com"
	
    Scenario: See latest comments on dashboard
      Then I should see "Recent Comments"
        And I should see "TB Treatment Project"

    Scenario: Access comments page from dashboard and edit them
      When I follow "view_comments"
      Then I should be on the comments page
        And I should see "TB Treatment Project"
        And I should see "comment1"

      When I follow "Edit"
        And I fill in "Title" with "comment1 edited"
        And I press "Update"
      Then I should see "comment1 edited"


    Scenario: Reporter can see only comments from his organization
      Given a organization exists with name: "USAID"
        And a data_response should exist with data_request: the data_request, organization: the organization
        And a reporter exists with email: "other_user@hrtapp.com", organization: the organization, current_response: the data_response
        And a project exists with name: "Other Project", data_response: the data_response
        And a comment exists with title: "title2", comment: "comment2", commentable: the project, user: the reporter
      When I go to the comments page
      Then I should see "comment1"
        And I should not see "comment2"
