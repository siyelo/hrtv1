Feature: NGO/donor can view review page
  In order to view all my data
  As a NGO/Donor
  I want to be able to see review screen

Background:
  Given organizations, reporters, data request, data responses, projects
  Given I am signed in as an admin
  When I follow "Dashboard"
  And I follow "Review submitted data responses"
  And I follow "Show"

@admin_review_screen @javascript
Scenario: Manage comments on data responses (with Javascript)
  And I follow "Create new" within ".data_responses"
  And I fill in "Title" with "comment title"
  And I fill in "Comment" with "comment body"
  And I press "Create comment"
  Then I should see "comment title"
  And I should see "comment body"
  When I follow "Edit" within ".data_responses .resources.comments"
  And I fill in "Title" with "new comment title"
  And I fill in "Comment" with "new comment body"
  And I press "Update comment"
  Then I should see "new comment title"
  And I should see "new comment body"
  When I will confirm a js popup
  And I follow "Delete" within ".data_responses .resources.comments"
  Then I should not see "new comment title"
  And I should not see "new comment body"

@admin_review_screen @javascript
Scenario: Manage comments on project (with Javascript)
  When I follow "Show/hide details..."
  And I click element ".project .descr"
  And I follow "Create new" within ".project"
  And I fill in "Title" with "comment title"
  And I fill in "Comment" with "comment body"
  And I press "Create comment"
  Then I should see "comment title"
  And I should see "comment body"
  When I follow "Edit" within ".project .resources.comments"
  And I fill in "Title" with "new comment title"
  And I fill in "Comment" with "new comment body"
  And I press "Update comment"
  Then I should see "new comment title"
  And I should see "new comment body"
  When I will confirm a js popup
  And I follow "Delete" within ".project .resources.comments"
  Then I should not see "new comment title"
  And I should not see "new comment body"

@admin_review_screen @javascript
Scenario: Manage comments on activities (with Javascript)
  When I follow "Show/hide details..."
  And I click element ".project .descr"
  And I click element ".activity .descr"
  And I follow "Create new" within ".activity"
  And I fill in "Title" with "comment title"
  And I fill in "Comment" with "comment body"
  And I press "Create comment"
  Then I should see "comment title"
  And I should see "comment body"
  When I follow "Edit" within ".activity .resources.comments"
  And I fill in "Title" with "new comment title"
  And I fill in "Comment" with "new comment body"
  And I press "Update comment"
  Then I should see "new comment title"
  And I should see "new comment body"
  When I will confirm a js popup
  And I follow "Delete" within ".activity .resources.comments"
  Then I should not see "new comment title"
  And I should not see "new comment body"
