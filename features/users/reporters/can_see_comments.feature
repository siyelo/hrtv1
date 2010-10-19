Feature: Reporter can see comments
  In order to help reporters see missed areas
  As a reporter
  I want to be able to see comments that reviewers have made

#  - a comment feed page
#  - that shows 1 or 2 with a link to more
@run
Scenario: See comment excerpts on dashboard
  Given a basic org + reporter profile, with data response, signed in
  Given the following projects 
    | name                 | request | organization |
   | TB Treatment Project | Req1    | UNDP          | 
  Given the following comments 
    | project              | title   | comment |
    | TB Treatment Project | title1  | the first comment |
  When I follow "Dashboard"
  Then I should see "Activity Feed"
  And I should see "Comment: "
  And I should see "title1"
  And I should see "on Project: "
  And I should see "TB Treatment Project"
  
Scenario: See full comment listing
  - full listing
  - reporter/comments

Scenario: See comment detail
  - reporter/comments/1/

#  - click to respond to a comment 
Scenario: respond to comment

