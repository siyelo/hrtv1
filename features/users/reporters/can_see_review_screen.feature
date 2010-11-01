Feature: NGO/donor can view review page
  In order to view all my data
  As a NGO/Donor
  I want to be able to see review screen

Background:
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
  Given the following reporters 
    | name             | organization |
    | who_user         | WHO          |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "WHO"
  Given a project with name "TB Treatment Project" for request "Req1" and organization "WHO"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project", request "Req1" and organization "WHO"
  Given I am signed in as "who_user"
  When I follow "Dashboard"
  And I follow "Edit"
  When I follow "My Data"
  And I follow "Review"

@reporter_review_screen @javascript
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

@reporter_review_screen @javascript
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

@reporter_review_screen @javascript
Scenario: Manage comments on activities (with Javascript)
  When I click element "#project_details"
  And I click element ".project .descr"
  And I click element ".activity_details"
  And I click element ".activity .descr"
  And I click element ".activity .comment_details"
  And I follow "+ Add Comment" within ".activity"
  And I fill in "Title" with "comment title"
  And I fill in "Comment" with "comment body"
  And I press "Create comment"
  Then I should see "comment title"
  And I should see "comment body"
  When I follow "Edit" within ".activity .resources"
  And I fill in "Title" with "new comment title"
  And I fill in "Comment" with "new comment body"
  And I press "Update comment"
  Then I should see "new comment title"
  And I should see "new comment body"
  When I will confirm a js popup
  And I follow "Delete" within ".activity .resources"
  Then I should not see "new comment title"
  And I should not see "new comment body"
