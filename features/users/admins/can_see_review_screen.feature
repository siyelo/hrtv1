Feature: NGO/donor can view review page
  In order to view all my data
  As a NGO/Donor
  I want to be able to see review screen

Background:
  Given organizations, reporters, data request, data responses, projects
  Given I am signed in as an admin
  When I follow "Dashboard"
  And I follow "Review data responses"
  And I follow "Show"

@admin_review_screen @javascript
Scenario: Manage comments on data responses (with Javascript)
  When I click element ".comment_details"
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
  Then I can manage the comments

@admin_review_screen @javascript
Scenario: See all the nested sub-tabs (with Javascript)
  Then I should see tabs for comments,projects,non-project activites
  Then I should see tabs for comments,activities,other costs 
  Then I should see tabs for comments,sub-activities when activities already open
  
