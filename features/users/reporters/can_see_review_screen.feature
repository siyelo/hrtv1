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

@reporter_review_screen @javascript
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
