Feature: Admin can see review page
  In order to view all my data
  As a sysadmin
  I want to be able to see review screen

  Background:
    Given an organization exists with name: "GoR"
      And a data_request exists with title: "Req1", organization: the organization
      And an organization exists with name: "UNDP"
      And a reporter exists with email: "undp_user@hrtapp.com", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "TB Treatment Project", data_response: the data_response
      And a comment exists with title: "title1", comment: "comment1", commentable: the project
      And an activity exists with name: "TB Drugs procurement", data_response: the data_response, project: the project
      And an organization exists with name: "USAID"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with name: "Other Project", data_response: the data_response
      And a comment exists with title: "title2", comment: "comment2", commentable: the project
      And an organization exists with name: "SysAdmin Org"
      And a sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
      And I am signed in as "sysadmin@hrtapp.com"
      When I follow "Home"
      And I follow "Organizations"
      And I follow "UNDP"

  @javascript @wip
  Scenario: Manage comments on data responses (with Javascript)
    When wait a few moments
      And I follow "+ Add Comment"
      And I fill in "Title" with "comment title"
      And I fill in "Comment" with "comment body"
      And I press "Create Comment"
    Then I should see "comment title"
      And I should see "comment body"

    When I follow "Edit" within ".comments"
      And I fill in "Title" with "new comment title"
      And I fill in "Comment" with "new comment body"
      And I press "Update Comment"
    Then I should see "new comment title"
      And I should see "new comment body"

    When I confirm the popup dialog
      And I follow "Delete" within ".comments"
    Then I should not see "new comment title"
      And I should not see "new comment body"


  Scenario: Manage comments on project (with Javascript)
    When I follow "Other Project"
      And I fill in "Title" with "comment title"
      And I fill in "Comment" with "comment body"
      And I press "Create Comment"
    Then I should see "comment title"
      And I should see "comment body"

  Scenario: Manage comments on activities (with Javascript)
    When I follow "Projects"
      And I follow "TB Drugs procurement"
      And I fill in "Title" with "comment title"
      And I fill in "Comment" with "comment body"
      And I press "Create Comment"
    Then I should see "comment title"
      And I should see "comment body"

  @javascript @wip
  Scenario: See all the nested sub-tabs (with Javascript)
    Then I should see tabs for comments,projects,non-project activites
      And I should see tabs for comments,activities,other costs
      And I should see tabs for comments,sub-activities when activities already open
