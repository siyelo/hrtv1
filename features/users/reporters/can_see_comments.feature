Feature: Reporter can see comments
  In order to help reporters see missed areas
  As a reporter
  I want to be able to see comments that reviewers have made

Background:
  Given a basic org + reporter profile, with data response, signed in
  And a comment exists with title: "title1", comment: "comment1", commentable: the project

@reporter_comments
Scenario: See latest comments on dashboard
  When I follow "Dashboard"
  Then I should see "Recent Comments"
  And I should see "title1"
  And I should see "on Project: "
  And I should see "TB Treatment Project"

@reporter_comments
Scenario: Access comments page from dashboard and edit them
  When I follow "Dashboard"
  And I follow "all comments"
  Then I should be on the comments page
  And I should see "TB Treatment Project"
  And I should see "comment1"
  When I follow "Edit"
  And I fill in "Title" with "comment1 edited"
  And I press "Update"
  Then I should see "comment1 edited"

@reporter_comments
Scenario: Reporter can see only comments from his organization
  Given a organization exists with name: "USAID"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "other_user", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Other Project", data_response: the data_response
  And a comment exists with title: "title2", comment: "comment2", commentable: the project, user: the reporter
  When I go to the comments page
  Then I should see "comment1"
  And I should not see "comment2"
