Feature: Reporter can upload classifications
  In order to increase the quality of information reported
  As a reporter
  I want to be able to upload classifications

  Background:
    # Given the following code structure
    #
    #               / code111
    #      / code11 - code112
    # code1
    #      \ code12 - code121
    #               \ code122
    #
    #               / code211
    #      / code21 - code212
    # code2
    #      \ code22 - code221
    #               \ code222

    # level 1
    Given a mtef_code "mtef1" exists with short_display: "mtef1"
      And a cost_category_code exists with short_display: "cost_category1"
      And a service_level exists with short_display: "service_level1"
      And a location exists with short_display: "location1"

      And an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And an organization exists with name: "organization2"
      And a data_response exists with data_request: the data_request, organization: the organization
      And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
      And a project exists with name: "Project", data_response: the data_response
      And an activity exists with name: "Activity", data_response: the data_response, project: the project, description: "Activity description", budget: 5000000, spend: 6000000
      And the location is one of the activity's locations
      And I am signed in as "reporter"
      And I follow "data_request1"
      And I follow "Projects"
      And I follow "Activity description"



    Scenario Outline: Reporter can download Purposes template
      When I follow "<type>"
        And I follow "Purposes"
        And I follow "Download template"
      Then I should see "mtef1"
        And I should not see "cost_category1"
        And I should not see "service_level1"
        And I should not see "location1"

      Examples:
      | type   |
      | Budget |
      | Spend  |


    Scenario Outline: Reporter can download Inputs template
      When I follow "<type>"
        And I follow "Inputs"
        And I follow "Download template"
      Then I should see "cost_category1"
        And I should not see "mtef1"
        And I should not see "service_level1"
        And I should not see "location1"

      Examples:
      | type   |
      | Budget |
      | Spend  |


    Scenario Outline: Reporter can download Locations template
      When I follow "<type>"
        And I follow "Locations"
        And I follow "Download template"
      Then I should see "location1"
        And I should not see "mtef1"
        And I should not see "cost_category1"
        And I should not see "service_level1"

      Examples:
      | type   |
      | Budget |
      | Spend  |


    Scenario Outline: Reporter can download Service Levels template
      When I follow "<type>"
        And I follow "Service Levels"
        And I follow "Download template"
      Then I should see "service_level1"
        And I should not see "mtef1"
        And I should not see "cost_category1"
        And I should not see "location1"

      Examples:
      | type   |
      | Budget |
      | Spend  |


    Scenario Outline: Reporter can upload Purposes
      When I follow "<type>"
        And I follow "Purposes"
        And I attach the file "spec/fixtures/classifications_purposes.csv" to "File" within ".upload_box"
        And I press "Upload"
      Then I should see "Activity classification was successfully uploaded."
        And I should be on the budget classification page for "Activity"
        And the "mtef1" field should contain "20"
        And the "mtef1" percentage field should contain "10"

      Examples:
      | type   |
      | Budget |
      | Spend  |


    Scenario Outline: Reporter can upload Purposes
      When I follow "<type>"
        And I follow "Inputs"
        And I attach the file "spec/fixtures/classifications_inputs.csv" to "File" within ".upload_box"
        And I press "Upload"
      Then I should see "Activity classification was successfully uploaded."
        And I should be on the budget classification page for "Activity"
        And the "cost_category1" field should contain "20"
        And the "cost_category1" percentage field should contain "10"

      Examples:
      | type   |
      | Budget |
      | Spend  |


    Scenario Outline: Reporter can upload Locations
      When I follow "<type>"
        And I follow "Locations"
        And I attach the file "spec/fixtures/classifications_locations.csv" to "File" within ".upload_box"
        And I press "Upload"
      Then I should see "Activity classification was successfully uploaded."
        And I should be on the budget classification page for "Activity"
        And the "location1" field should contain "20"
        And the "location1" percentage field should contain "10"

      Examples:
      | type   |
      | Budget |
      | Spend  |


    Scenario Outline: Reporter can upload Service Levels
      When I follow "<type>"
        And I follow "Service Levels"
        And I attach the file "spec/fixtures/classifications_service_levels.csv" to "File" within ".upload_box"
        And I press "Upload"
      Then I should see "Activity classification was successfully uploaded."
        And I should be on the budget classification page for "Activity"
        And the "service_level1" field should contain "20"
        And the "service_level1" percentage field should contain "10"

      Examples:
      | type   |
      | Budget |
      | Spend  |
