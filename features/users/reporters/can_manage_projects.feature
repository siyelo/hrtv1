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
      And I follow "data_request1"
      And a project "Project5" exists with name: "Project5", data_response: data_response "data_response"
      And a funding_flow exists with from: organization "organization3", to: organization "organization2", project: project "Project5", id: "3"
      And a project "Project6" exists with name: "Project6", data_response: data_response "data_response1"
      And I follow "Projects"

    Scenario: Reporter can CRUD projects
      When I follow "Project"
        And I fill in "Name" with "Project1"
        And I fill in "Description" with "Project1 description"
        And I fill in "Start date" with "2011-01-01"
        And I fill in "End date" with "2011-12-01"
        And I select "Euro (EUR)" from "Currency override"
        And I press "Create Project"
      Then I should see "Project was successfully created"
      When I fill in "Name" with "Project2"
      And I fill in "Description" with "Project2 description"
      And I press "Update Project"
      Then I should see "Project was successfully updated"
      When I follow "Delete this Project"
      Then I should see "Project was successfully destroyed"

    Scenario Outline: Edit project dates, see feedback messages for start and end dates
      When I follow "Project"
        And I fill in "Name" with "Some Project"
        And I fill in "Start date" with "<start_date>"
        And I fill in "End date" with "<end_date>"
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


    @javascript @wip
    Scenario: A reporter can create in flows for a project
      When I follow "Project"
        And I fill in "Name" with "Project1"
        And I fill in "Description" with "Project1 description"
        And I fill in "Start date" with "2011-01-01"
        And I fill in "End date" with "2011-12-01"
        And I follow "Add funding source"
        And I fill in "Spent" with "11" within ".fields"
        And I fill in "Q4 08-09" with "22" within ".fields .spend"
        And I fill in "Q1 09-10" with "33" within ".fields .spend"
        And I fill in "Q2 09-10" with "44" within ".fields .spend"
        And I fill in "Q3 09-10" with "55" within ".fields .spend"
        And I fill in "Q4 09-10" with "66" within ".fields .spend"
        And I fill in "Budget" with "11" within ".fields"
        And I fill in "Q4 08-09" with "22" within ".fields .budget"
        And I fill in "Q1 09-10" with "33" within ".fields .budget"
        And I fill in "Q2 09-10" with "44" within ".fields .budget"
        And I fill in "Q3 09-10" with "55" within ".fields .budget"
        And I fill in "Q4 09-10" with "66" within ".fields .budget"
        And I press "Create Project"
      Then I should see "Project was successfully created"

      When I follow "Project1"
      Then the "Spent" field within ".fields" should contain "11"
        And the "Q4 08-09" field within ".fields .spend" should contain "22"
        And the "Q1 09-10" field within ".fields .spend" should contain "33"
        And the "Q2 09-10" field within ".fields .spend" should contain "44"
        And the "Q3 09-10" field within ".fields .spend" should contain "55"
        And the "Q4 09-10" field within ".fields .spend" should contain "66"

        And the "Budget" field within ".fields" should contain "11"
        And the "Q4 08-09" field within ".fields .budget" should contain "22"
        And the "Q1 09-10" field within ".fields .budget" should contain "33"
        And the "Q2 09-10" field within ".fields .budget" should contain "44"
        And the "Q3 09-10" field within ".fields .budget" should contain "55"
        And the "Q4 09-10" field within ".fields .budget" should contain "66"

      When I follow "Edit" within ".funding_flows"
        And I fill in "Budget" with "7778" within ".fields"
        And I press "Update Project"
        And I follow "Project1"
      Then the "Budget" field within ".fields" should contain "7778"
    
    @wip
    Scenario: A Reporter can bulk link their projects to those from other organizations
      Then I should see "Project5"
      When I follow "Link to Funders"
      Then I should see "Project5"
      When select "Project6" from "funding_flows_3"
        And I press "Update"
      Then I should see "Your projects have been successfully updated"

    @wip
    Scenario: A Reporter can bulk unlink their projects to those from other organizations
      Then I should see "Project5"
      When I follow "Link to Funders"
      Then I should see "Project5"
      When select "" from "funding_flows_3"
        And I press "Update"
      Then I should see "Your projects have been successfully updated"
    
    @wip
    Scenario: A Reporter can select project missing or project unknown for their FS from the bulk edit page
      Then I should see "Project5"
      When I follow "Link to Funders"
      Then I should see "Project5"
      When select "<Project not listed or unknown>" from "funding_flows_3"
        And I press "Update"
      Then I should see "Your projects have been successfully updated"
