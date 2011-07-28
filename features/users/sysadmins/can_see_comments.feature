Feature: Admin can see comments
  In order to help reporters see missed areas
  As a sysadmin
  I want to be able to see comments that admins have made

  Background:
    Given an organization exists with name: "GoR"
    And a data_request exists with title: "Req1", organization: the organization
    And an organization exists with name: "UNDP"
    And a reporter exists with email: "undp_user@hrtapp.com", organization: the organization
    And a data_response should exist with data_request: the data_request, organization: the organization
    And a project exists with name: "TB Treatment Project", data_response: the data_response
    And a comment exists with title: "title1", comment: "comment1", commentable: the project
    And an activity exists with name: "TB Drugs procurement", data_response: the data_response, project: the project
    And an organization exists with name: "USAID"
    And a data_response should exist with data_request: the data_request, organization: the organization
    And a project exists with name: "Other Project", data_response: the data_response
    And a comment exists with title: "title2", comment: "comment2", commentable: the project
    Given an organization exists with name: "SysAdmin Org"
    And a sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
    And I am signed in as "sysadmin@hrtapp.com"

    Scenario: See latest comments on dashboard
      Then I should see "Recent Comments"
        And I should see "TB Treatment Project"
        And I should see "Other Project"

    Scenario: Access comments page from dashboard and edit them
        And I follow "view all"
      Then I should be on the admin comments page
        And I should see "TB Treatment Project"
        And I should see "comment1"
      When I follow "Edit"
      And I fill in "Comment" with "comment3"
      And I press "Update"
      Then I should see "comment3"

    Scenario: Admin can see all comments
      When I go to the admin comments page
      Then I should see "comment1"
        And I should see "comment2"
