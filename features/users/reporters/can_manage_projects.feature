Feature: Reporter can manage projects
  In order to track information
  As a reporter
  I want to be able to manage my projects

  Background:
    Given an organization "organization3" exists with name: "organization3"
    And a data_request "data_request1" exists with title: "data_request1"
    And a data_request "data_request2" exists with title: "data_request2"
    And an organization "organization2" exists with name: "organization2"
    Then data_response "data_response" should exist with data_request: data_request "data_request1", organization: organization "organization2"
    And data_response "data_response1" should exist with data_request: data_request "data_request2", organization: organization "organization3"
    And a reporter exists with email: "reporter@hrtapp.com", organization: organization "organization2"
    And I am signed in as "reporter@hrtapp.com"
    And I go to the set request page for "data_request1"
    And a project "Project5" exists with name: "Project5", data_response: data_response "data_response"
    And a project "Project6" exists with name: "Project6", data_response: data_response "data_response1"
    And I follow "Projects"

  Scenario: Reporter can CRUD projects
    When I follow "Project"
    And I fill in "Name" with "Project1"
    And I fill in "Description" with "Project1 description"
    And I fill in "project[start_date]" with "2011-01-01"
    And I fill in "project[end_date]" with "2011-12-01"
    And I select "Euro (EUR)" from "Currency override"
    And I select "organization3" from "project_in_flows_attributes_0_organization_id_from"
    And I fill in "project_in_flows_attributes_0_spend" with "10"
    And I fill in "project_in_flows_attributes_0_budget" with "20"
    And I press "Create Project"
    Then I should see "Project successfully created"
    When I follow "Project1"
    And I fill in "Name" with "Project2"
    And I fill in "Description" with "Project2 description"
    And I press "Update Project"
    Then I should see "Project successfully updated"
    When I follow "Delete this Project"
    Then I should see "Project was successfully destroyed"

  # cant run in js mode.
  # right now, this search yields the problems with jQuery Autocomplete combobox and capybara
  #http://www.google.co.za/search?sourceid=chrome&ie=UTF-8&q=jquery+autocomplete+combobox+capybara
  Scenario: A reporter can select a funder for a project
    When I follow "Project"
    And I fill in "Name" with "Project1"
    And I fill in "Description" with "Project1 description"
    And I fill in "project[start_date]" with "2011-01-01"
    And I fill in "project[end_date]" with "2011-12-01"
    And I select "organization2" from "project_in_flows_attributes_0_organization_id_from"
    And I fill in "project_in_flows_attributes_0_spend" with "11"
    And I fill in "project_in_flows_attributes_0_budget" with "12"
    And I press "Create Project"
    Then I should see "Project successfully created"
    And I should see "organization2" within ".js_implementer_container"

  Scenario Outline: Edit project dates, see feedback messages for start and end dates
    When I follow "Project"
    And I fill in "Name" with "Some Project"
    And I fill in "project[start_date]" with "<start_date>"
    And I fill in "project[end_date]" with "<end_date>"
    And I press "Create Project"
    Then I should see "<message>"
    And I should see "<specific_message>"

    Examples:
      | start_date | end_date   | message                              | specific_message                      |
      |            | 2010-01-02 | Oops, we couldn't save your changes. | Start date can't be blank            |
      | 123        | 2010-01-02 | Oops, we couldn't save your changes. | Start date is not a valid date        |
      | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date. |


  Scenario: A reporter can create comments for a workplan (response) and see errors
    When I follow "Projects"
    And I press "Create Comment"
    Then I should see "You cannot create blank comment."
    When I fill in "Comment" with "Comment body"
    And I press "Create Comment"
    Then I should see "Comment body"

  Scenario: A reporter can create comments for a project
    Given a project exists with name: "project1", data_response: data_response "data_response"
    When I follow "Projects"
    And I follow "project1"
    And I press "Create Comment"
    Then I should see "You cannot create blank comment."
    When I fill in "Comment" with "Comment body"
    And I press "Create Comment"
    Then I should see "Comment body"
