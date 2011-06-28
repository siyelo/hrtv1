Feature: Admin can see comments
  In order to help reporters see missed areas
  As an admin
  I want to be able to see comments that admins have made

  Background:
    Given an organization exists with name: "GoR"
    And a data_request exists with title: "Req1", organization: the organization
    And an organization exists with name: "UNDP"
    And a admin exists with username: "undp_user", organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And a project exists with name: "TB Treatment Project", data_response: the data_response
    And a comment exists with comment: "comment1", commentable: the project
    And an activity exists with name: "TB Drugs procurement", data_response: the data_response, project: the project
    And an organization exists with name: "USAID"
    And a data_response exists with data_request: the data_request, organization: the organization
    And a project exists with name: "Other Project", data_response: the data_response
    And a comment exists with comment: "comment2", commentable: the project



    Scenario: See latest comments on dashboard
      Given I am signed in as an admin
      When I follow "Dashboard"
      Then I should see "Recent Comments"
        And I should see "TB Treatment Project" within ".dashboard_comments"
        And I should see "Other Project" within ".dashboard_comments"


    Scenario: Access comments page from dashboard and manage them
      Given I am signed in as an admin
      When I follow "Dashboard"
        And I follow "all comments"
      Then I should be on the admin comments page
        And I should see "TB Treatment Project"
        And I should see "comment1"

      When I follow "Edit"
        And I fill in "Comment" with "comment3"
        And I press "Update"
      Then I should see "comment3"

      When I follow "Delete"
      Then I should not see "comment3"
