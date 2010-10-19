Feature: Reporter can see comments
  In order to help reporters see missed areas
  As a reporter
  I want to be able to see comments that reviewers have made

@reporter_comments
Scenario: See latest comments on dashboard
  Given a basic org + reporter profile, with data response, signed in
  Given the following projects 
    | name                 | request | organization |
   | TB Treatment Project | Req1    | UNDP          | 
  Given the following comments 
    | project              | title   | comment |
    | TB Treatment Project | title1  | the first comment |
  When I follow "Dashboard"
  Then I should see "Recent Comments"
  And I should see "title1"
  And I should see "on Project: "
  And I should see "TB Treatment Project"

@reporter_comments
Scenario: Access comments page from dashboard and edit them
  Given a basic org + reporter profile, with data response, signed in
  Given the following projects 
    | name                 | request | organization |
   | TB Treatment Project | Req1    | UNDP          | 
  Given the following comments 
    | project              | title   | comment |
    | TB Treatment Project | title1  | the first comment |
    | TB Treatment Project | title2  | the second comment |
  When I follow "Dashboard"
  And I follow "all comments"
  Then I should be on the comments page
  And I should see "TB Treatment Project"
  And I should see "the first comment"
  When I follow "Edit"
  And I fill in "Title" with "the third comment"
  And I press "Update"
  And I should see "the third comment"

@reporter_comments
Scenario: Reporter can see only comments from his organization
  Given the following organizations 
    | name   |
    | UNDP   |
    | USAID  |
    | GoR    |
  Given the following reporters 
     | name         | organization |
     | undp_user    | UNDP         |
  Given a data request with title "Req1" from "GoR"
  Given a data response to "Req1" by "UNDP"
  Given a data response to "Req1" by "USAID"
  Given the following projects 
    | name                 | request | organization |
    | TB Treatment Project | Req1    | UNDP         |
    | Other Project        | Req1    | USAID        |
  Given the following comments 
    | project              | title   | comment |
    | TB Treatment Project | title1  | comment1 |
    | Other Project        | title2  | comment2 |
  Given I am signed in as "undp_user"
  When I follow "Dashboard"
  And I follow "Edit"
  When I go to the comments page
  Then I should see "comment1"
  Then I should not see "comment2"

# maybe later ?
#@reporter_comments
#Scenario: See full comment detail when you click on the comment on the listing page

@reporter_comments
Scenario: Respond to comment
