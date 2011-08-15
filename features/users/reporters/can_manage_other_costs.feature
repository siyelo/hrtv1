# TODO: fix these - the multiple responses i think are the cause
@run
Feature: Reporter can manage other costs
  In order to track information
  As a reporter
  I want to be able to manage other costs

  Background:
  
  Given an organization exists with name: "organization1"
  And a data_request exists with title: "data_request1"
  And an organization "my_organization" exists with name: "organization2"
  Then data_response should exist with data_request: the data_request, organization: the organization
  And a reporter exists with email: "reporter@hrtapp.com", organization: organization "my_organization"
  And a project exists with name: "project1", data_response: the data_response
  And I am signed in as "reporter@hrtapp.com"
  And I follow "data_request1"
  And I follow "Projects"

  Scenario: Reporter can CRUD other costs
    When I follow "Add Other Costs now"
    Then I should see "Create Other Cost"
    When I fill in "Name" with "other_cost1"
      And I fill in "Description" with "other_cost2 description"
      And I select "project1" from "Project"
      And I fill in "Start date" with "2010-01-01"
      And I fill in "End date" with "2010-03-01"
      And I press "Save & Classify >"
    Then I should see "Other Cost was successfully created"
    When I follow "other_cost1"
      And I fill in "Name" with "other_cost2"
      And I press "Save & Classify >"
    Then I should see "Other Cost was successfully updated"
      And I should see "other_cost2"
      And I should not see "other_cost1"
    When I follow "other_cost2"
      And I follow "Delete this Other Cost"
    Then I should see "Other Cost was successfully destroyed"
      And I should not see "other_cost1"
      And I should not see "other_cost2"
  
  Scenario: Reported can create other cost with automatically created project
    When I follow "Add Other Costs now"
      And I fill in "Name" with "other_cost1"
      And I fill in "Description" with "other_cost2 description"
      And I fill in "Start date" with "2010-01-01"
      And I fill in "End date" with "2010-12-01"
      And I select "<Automatically create a project for me>" from "Project"
      And I press "Save & Classify >"
    Then I should see "Other Cost was successfully created. Click here to enter the funding sources for the automatically created project."

  Scenario: Reporter can create an other costs at an Org level (i.e. without a project)
    When I follow "Add Other Costs now"
      And I fill in "Name" with "other_cost1"
      And I fill in "Description" with "other_cost1"
      And I fill in "Start date" with "2010-01-01"
      And I fill in "End date" with "2010-03-01"
      And I press "Save & Classify >"
    Then I should see "Other Cost was successfully created"

  @wip
  Scenario: A reporter can create comments for an other cost and see comment errors
    Given an other cost exists with project: the project, description: "OtherCost1 description", data_response: the data_response
    When I follow "Projects"
      And I follow "OtherCost1 description"
      And I press "Create Comment"
    Then I should see "can't be blank" within "#comment_comment_input"

    When I fill in "Comment" with "Comment body"
      And I press "Create Comment"
    Then I should see "Comment was successfully created"
      And I should see "Comment body"

  @wip
  Scenario: If the data_request budget is not checked the budget should not show up in the other costs screen
    Given I follow "Sign Out"
      And an organization exists with name: "organization5"
      And a data_request exists with title: "data_request2", budget: false
     Then a data_response should exist with data_request: the data_request, organization: the organization
      And a reporter exists with email: "reporter2@hrtapp.com", organization: the organization
    When I am signed in as "reporter2@hrtapp.com"
      And I follow "data_request2"
      And a project exists with name: "project1", data_response: the data_response
      And I follow "Projects"
      And I follow "Add Other Costs now"
    Then I should not see "Budget (planned expenditure)"
