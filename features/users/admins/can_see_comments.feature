Feature: Admin can see comments
  In order to help reporters see missed areas
  As an admin
  I want to be able to see comments that admins have made

@admin_comments
Scenario: See latest comments on dashboard
  Given organizations, reporters, data request, data responses, projects
  Given the following comments 
    | project              | title   | comment |
    | TB Treatment Project | title1  | comment1 |
    | Other Project        | title2  | comment2 |
  Given I am signed in as an admin
  When I follow "Dashboard"
  Then I should see "Recent Comments"
  And I should see "title1"
  And I should see "on Project: "
  And I should see "TB Treatment Project"
  And I should see "title2"
  And I should see "on Project: "
  And I should see "Other Project"

@admin_comments
Scenario: Access comments page from dashboard and edit them
  Given organizations, reporters, data request, data responses, projects
  Given the following comments 
    | project              | title   | comment |
    | TB Treatment Project | title1  | comment1 |
    | Other Project        | title2  | comment2 |
  Given I am signed in as an admin
  When I follow "Dashboard"
  And I follow "all comments"
  Then I should be on the comments page
  And I should see "TB Treatment Project"
  And I should see "comment1"
  When I follow "Edit"
  And I fill in "Title" with "comment3"
  And I press "Update"
  And I should see "comment3"

@admin_comments
Scenario: Admin can see all comments
  Given organizations, reporters, data request, data responses, projects
  Given the following comments 
    | project              | title   | comment |
    | TB Treatment Project | title1  | comment1 |
    | Other Project        | title2  | comment2 |
  Given I am signed in as an admin
  When I go to the comments page
  Then I should see "comment1"
  And I should see "comment2"
