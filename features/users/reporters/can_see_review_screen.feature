@wip
Feature: Reporter can view review page
  In order to view all my data
  As a reporter
  I want to be able to see review screen

  Background:
    Given an organization exists with name: "UNAIDS"
      And a data_request exists with title: "Req1", organization: the organization
      And an organization exists with name: "WHO"
      And a reporter exists with username: "who_user", organization: the organization
      And a data_response exists with data_request: the data_request, organization: the organization
      And a project exists with name: "TB Treatment Project", data_response: the data_response
      And an activity exists with name: "TB Drugs procurement", project: the project, data_response: the data_response
      And I am signed in as "who_user"
    When I follow "Home"
      And I follow "Edit"
      And I follow "Review"


    @javascript
    Scenario: Manage comments on data responses (with Javascript)
      Given wait a few moments
      When I click element ".comment_details"
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


    @javascript
    Scenario: Manage comments on project (with Javascript)
      Then wait a few moments
      When I click element "#project_details"
        And I click element ".project .descr"
        And I click element ".project .comment_details"
        And I follow "+ Add Comment" within ".project"
        And I fill in "Title" with "comment title"
        And I fill in "Comment" with "comment body"
        And I press "Create Comment"
      Then I should see "comment title"
        And I should see "comment body"
      When I follow "Edit" within ".project .resources"
        And I fill in "Title" with "new comment title"
        And I fill in "Comment" with "new comment body"
        And I press "Update Comment"
      Then I should see "new comment title"
        And I should see "new comment body"
      When I confirm the popup dialog
        And I follow "Delete" within ".project .resources"
      Then I should not see "new comment title"
        And I should not see "new comment body"


    @javascript
    Scenario: Manage comments on activities (with Javascript)
      Then I can manage the comments


    @javascript
    Scenario: See all the nested sub-tabs (with Javascript)
      Then I should see tabs for comments,projects,non-project activites
        And I should see tabs for comments,activities,other costs
        And I should see tabs for comments,sub-activities when activities already open
