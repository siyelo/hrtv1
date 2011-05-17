Feature: Reporter can manage classifications
  In order to increase the quality of information reported
  As a reporter
  I want to be able to classify activities

  @run
  Scenario: Repoter can edit Purposes classifications for Spent
    # Given the following code structure
    #
    #               / code111
    #      / code11 - code112
    # code1
    #      \ code12

    # level 1
    Given a mtef_code "mtef1" exists with short_display: "mtef1"
      # level 2
      And a mtef_code "mtef11" exists with short_display: "mtef11", parent: mtef_code "mtef1"
      And a mtef_code "mtef12" exists with short_display: "mtef12", parent: mtef_code "mtef1"
      # level 3
      And a mtef_code "mtef111" exists with short_display: "mtef111", parent: mtef_code "mtef11"
      And a mtef_code "mtef112" exists with short_display: "mtef112", parent: mtef_code "mtef11"

      And an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And an organization exists with name: "organization2"
      And a data_response exists with data_request: the data_request, organization: the organization
      And a project exists with name: "Project", data_response: the data_response
      And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
      And an activity exists with name: "Activity", data_response: the data_response, project: the project, description: "Activity description", budget: 100, spend: 200

      And a coding_spend exists with activity: the activity, code: mtef_code "mtef11", amount: 44
      And a coding_spend exists with activity: the activity, code: mtef_code "mtef12", amount: 55
      And I am signed in as "reporter"

      When I follow "data_request1"
      And I follow "Projects"
      And I follow "Purposes"
      Then I should see "Purposes" within "h1"
      And I fill in "mtef11" with "100"
      And I fill in "mtef12" with "200"
      And I press "Save"
      Then I should see "Purposes classifications for Spent were successfully saved"

  @run1
  Scenario: Reporter can add a purpose
    Given I am on the purposes classification page
    And I follow "Add Purpose" within "project_1"
    Then I should see the search purpose box
