Feature: NGO/donor can view review page
  In order to view all my data
  As a NGO/Donor
  I want to be able to see review screen

Background:
  Given an organization exists with name: "GoR"
  And a data_request exists with title: "Req1", requesting_organization: the organization
  And an organization exists with name: "UNDP"
  And a reporter exists with username: "undp_user", organization: the organization
  And a data_response exists with data_request: the data_request, responding_organization: the organization
  And a project exists with name: "TB Treatment Project", data_response: the data_response
  And a comment exists with title: "title1", comment: "comment1", commentable: the project
  And an activity exists with name: "TB Drugs procurement", data_response: the data_response
  And the project is one of the activity's projects
  And an organization exists with name: "USAID"
  And a data_response exists with data_request: the data_request, responding_organization: the organization
  And a project exists with name: "Other Project", data_response: the data_response
  And a comment exists with title: "title2", comment: "comment2", commentable: the project
  And I am signed in as an admin
  When I follow "Dashboard"
  And I follow "Review Organization Expenditures and Budgets"
  And I follow "In Progress"
  And I follow "UNDP"

@admin_review_screen @javascript
Scenario: Manage comments on data responses (with Javascript)
  And I follow "+ Add Comment"
  And I fill in "Title" with "comment title"
  And I fill in "Comment" with "comment body"
  And I press "Create comment"
  Then I should see "comment title"
  And I should see "comment body"
  When I follow "Edit" within ".comments"
  And I fill in "Title" with "new comment title"
  And I fill in "Comment" with "new comment body"
  And I press "Update comment"
  Then I should see "new comment title"
  And I should see "new comment body"
  When I will confirm a js popup
  And I follow "Delete" within ".comments"
  Then I should not see "new comment title"
  And I should not see "new comment body"

@admin_review_screen @javascript
Scenario: Manage comments on project (with Javascript)
  When wait a few moments
  When I click element "#project_details"
  And I click element ".project .descr"
  And I click element ".project .comment_details"
  And I follow "+ Add Comment" within ".project"
  And I fill in "Title" with "comment title"
  And I fill in "Comment" with "comment body"
  And I press "Create comment"
  Then I should see "comment title"
  And I should see "comment body"
  When I follow "Edit" within ".project .resources"
  And I fill in "Title" with "new comment title"
  And I fill in "Comment" with "new comment body"
  And I press "Update comment"
  Then I should see "new comment title"
  And I should see "new comment body"
  When I will confirm a js popup
  And I follow "Delete" within ".project .resources"
  Then I should not see "new comment title"
  And I should not see "new comment body"

@admin_review_screen @javascript
Scenario: Manage comments on activities (with Javascript)
  When I click element "#project_details"
  And I click element "#projects .project .descr"
  And I click element "#projects .activity_details"
  And I click element "#projects .activity .descr"
  And I click element "#projects .activity .comment_details"
  And I follow "+ Add Comment" within ".activity"
  And I fill in "Title" with "comment title"
  And I fill in "Comment" with "comment body"
  And I press "Create comment"
  Then I should see "comment title"
  And I should see "comment body"
  When I follow "Edit" within "#projects .activity .resources"
  And I fill in "Title" with "new comment title"
  And I fill in "Comment" with "new comment body"
  And I press "Update comment"
  Then I should see "new comment title"
  And I should see "new comment body"
  When I will confirm a js popup
  And I follow "Delete" within "#projects .activity .resources"
  Then I should not see "new comment title"
  And I should not see "new comment body"

@admin_review_screen @javascript
Scenario: See all the nested sub-tabs (with Javascript)
  Then I should see tabs for comments,projects,non-project activites
  Then I should see tabs for comments,activities,other costs
  Then I should see tabs for comments,sub-activities when activities already open

