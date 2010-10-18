Feature: Reporter can see comments
  In order to help reporters see missed areas
  As a reporter
  I want to be able to see comments that reviewers have made

#  - a comment feed page
#  - that shows 1 or 2 with a link to more
@run
Scenario: See comment excerpt on dashboard
  Given a basic org + reporter profile, with data response, signed in
  When I follow "Dashboard"
  Then I should see "Activity Feed"

Scenario: See full comment listing
  - full listing
  - reporter/comments

Scenario: See comment detail
  - reporter/comments/1/

Scenario: add comment?
Scenario: edit comment?