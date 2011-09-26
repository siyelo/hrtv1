Feature: Reporter can enter a code breakdown for each activity
  In order to increase the quality of information reported
  As a reporter
  I want to be able to break down activities into individual codes

  Background:
  # Given the following code structure
  #
  #         / code111
  #    / code11 - code112
  # code1
  #    \ code12 - code121
  #         \ code122
  #
  #         / code211
  #    / code21 - code212
  # code2
  #    \ code22 - code221
  #         \ code222

    # level 1
    Given a mtef_code "mtef1" exists with id: 1, short_display: "mtef1"
      And a mtef_code "mtef2" exists with id: 2, short_display: "mtef2"
      And a cost_category_code exists with id: 3, short_display: "cost_category1"
      And an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization, current_response: the data_response
      And a project exists with name: "Project", data_response: the data_response
      And I am signed in as "reporter@hrtapp.com"
      And I go to the set request page for "data_request1"


    ############
    ### PURPOSES
    ############
    Scenario: Reporter can classify Purposes for activity (first level)
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      #since we used a factory above, need save to refresh cache by saving activity
      And I press "Save"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][coding_budget][1]" with "100"
      And I fill in "activity[classifications][coding_spend][1]" with "100"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And I should not see "Purposes by Current Budget are not classified and Purposes by Past Expenditure are not classified"
      And the "activity[classifications][coding_budget][1]" field should contain "100"
      And the "activity[classifications][coding_spend][1]" field should contain "100"


    Scenario: Reporter can classify Purposes for activity (second level)
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And a mtef_code "mtef11" exists with id: 11, short_display: "mtef11", parent: mtef_code "mtef1"
      And a mtef_code "mtef12" exists with id: 12, short_display: "mtef12", parent: mtef_code "mtef1"
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][coding_budget][11]" with "40"
      And I fill in "activity[classifications][coding_spend][11]" with "60"
      And I fill in "activity[classifications][coding_budget][12]" with "60"
      And I fill in "activity[classifications][coding_spend][12]" with "40"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And I should not see "Purposes by Current Budget are not classified and Purposes by Past Expenditure are not classified"
      And the "activity[classifications][coding_budget][11]" field should contain "40"
      And the "activity[classifications][coding_spend][11]" field should contain "60"
      And the "activity[classifications][coding_budget][12]" field should contain "60"
      And the "activity[classifications][coding_spend][12]" field should contain "40"

    Scenario: Reporter can classify Purposes for activity (third level)
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And a mtef_code "mtef11" exists with id: 11, short_display: "mtef11", parent: mtef_code "mtef1"
      And a mtef_code "mtef12" exists with id: 12, short_display: "mtef12", parent: mtef_code "mtef1"
      And a mtef_code "mtef111" exists with id: 111, short_display: "mtef111", parent: mtef_code "mtef11"
      And a mtef_code "mtef112" exists with id: 112, short_display: "mtef112", parent: mtef_code "mtef11"
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][coding_budget][111]" with "40"
      And I fill in "activity[classifications][coding_spend][111]" with "60"
      And I fill in "activity[classifications][coding_budget][112]" with "60"
      And I fill in "activity[classifications][coding_spend][112]" with "40"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And I should not see "Purposes by Current Budget are not classified and Purposes by Past Expenditure are not classified"
      And the "activity[classifications][coding_budget][111]" field should contain "40"
      And the "activity[classifications][coding_spend][111]" field should contain "60"
      And the "activity[classifications][coding_budget][112]" field should contain "60"
      And the "activity[classifications][coding_spend][112]" field should contain "40"

    @javascript
    Scenario: Reporter can classify Purposes for activity (third level)
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And a mtef_code "mtef11" exists with id: 11, short_display: "mtef11", parent: mtef_code "mtef1"
      And a mtef_code "mtef12" exists with id: 12, short_display: "mtef12", parent: mtef_code "mtef1"
      And a mtef_code "mtef111" exists with id: 111, short_display: "mtef111", parent: mtef_code "mtef11"
      And a mtef_code "mtef112" exists with id: 112, short_display: "mtef112", parent: mtef_code "mtef11"
      And I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"

      When I fill in "activity[classifications][coding_budget][111]" with "40"
      Then the "activity[classifications][coding_budget][11]" field should contain "40"
      And the "activity[classifications][coding_budget][1]" field should contain "40"

      When I fill in "activity[classifications][coding_spend][111]" with "40"
      Then the "activity[classifications][coding_spend][11]" field should contain "40"
      And the "activity[classifications][coding_spend][1]" field should contain "40"

      When I fill in "activity[classifications][coding_spend][1]" with "100"
      And I fill in "activity[classifications][coding_budget][1]" with "100"
      And I hover over ".tooltip" within ".values"
      Then I should see "This amount is not the same as the sum of the amounts underneath (100.00% - 40.00% = 60%)"

      When I fill in "activity[classifications][coding_spend][1]" with "10"
      And I hover over ".tooltip" within ".values"
      Then I should see "The root nodes do not add up to 100%"
      When I press "Save"
      And I confirm the popup dialog
      Then I should not see "Activity classification was successfully updated."

    Scenario: Reporter classify Purposes for activity and see flash error
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      #since we used a factory above, need save to refresh cache by saving activity
      And I press "Save"
      And I follow "Purposes" within ".section_nav"
      Then the "spend_purposes" checkbox should not be checked
      And the "budget_purposes" checkbox should not be checked
      When I fill in "activity[classifications][coding_budget][1]" with "99"
      And I fill in "activity[classifications][coding_spend][1]" with "99"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And the "spend_purposes" checkbox should not be checked
      And the "budget_purposes" checkbox should not be checked
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][coding_budget][1]" with "100"
      And I fill in "activity[classifications][coding_spend][1]" with "100"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And I should see "We are still busy processing changes to the classification tree."
      When I run delayed jobs
        And I refresh the page
      Then I should see "This Activity has not been fully classified"
      Then the "spend_purposes" checkbox should be checked
        And the "budget_purposes" checkbox should be checked

    Scenario: Reporter classify Locations for other cost and see flash error
      Given an other cost exists with name: "othercost1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the other_cost
      And a location exists with short_display: "National", id: 5
      When I follow "Projects"
      And I follow "othercost1"
      #since we used a factory above, need save to refresh cache by saving activity
      And I press "Save"
      And I follow "Locations" within ".section_nav"
      Then the "spend_locations" checkbox should not be checked
      And the "budget_locations" checkbox should not be checked
      When I fill in "other_cost[classifications][coding_budget_district][5]" with "100"
      And I fill in "other_cost[classifications][coding_spend_district][5]" with "100"
      And I press "Save"
      Then I should see "Other Cost was successfully updated."
      And I should see "We are still busy processing changes to the classification tree."
      When I run delayed jobs
        And I refresh the page
      Then I should see "This Other Cost has been fully classified"
      Then the "spend_locations" checkbox should be checked
        And the "budget_locations" checkbox should be checked

    @javascript
    Scenario: Reporter can copy Purposes from Current Budget to Past Expenditure
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][coding_budget][1]" with "100"
      And I follow "Copy across Budget classifications to Expenditure classifications"
      And I press "Save"
      And the "activity[classifications][coding_budget][1]" field should contain "100"
      And the "activity[classifications][coding_spend][1]" field should contain "100"

    @javascript
    Scenario: Reporter can copy Purposes from Past Expenditure to Current Budget
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][coding_spend][1]" with "100"
      And I follow "Copy across Expenditure classifications to Budget classifications"
      And I press "Save"
      And the "activity[classifications][coding_budget][1]" field should contain "100"
      And the "activity[classifications][coding_spend][1]" field should contain "100"

    Scenario: Reporter cannot clasify approved Activity
      Given an activity exists with name: "activity2", data_response: the data_response, project: the project, am_approved: true
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity2"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][coding_spend][1]" with "100"
      And I press "Save"
      Then I should see "Activity was already approved "


    ############
    ### INPUTS
    ############
    Scenario: Reporter can enter Inputs for activity
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Inputs" within ".section_nav"
      And I fill in "activity[classifications][coding_budget_cost_categorization][3]" with "100"
      And I fill in "activity[classifications][coding_spend_cost_categorization][3]" with "100"
      And I press "Save"
      Then I should see "Activity was successfully updated."
        And I should not see "Purposes by Current Budget are not classified and Purposes by Past Expenditure are not classified"
      When I run delayed jobs
        And I refresh the page
      Then the "activity[classifications][coding_budget_cost_categorization][3]" field should contain "100"
        And the "activity[classifications][coding_spend_cost_categorization][3]" field should contain "100"

    Scenario: Reporter can enter Inputs for activity and see flash error
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      #since we used a factory above, need save to refresh cache by saving activity
      And I press "Save"
      And I follow "Inputs" within ".section_nav"
      And I fill in "activity[classifications][coding_budget_cost_categorization][3]" with "99"
      And I fill in "activity[classifications][coding_spend_cost_categorization][3]" with "99"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And the "spend_inputs" checkbox should not be checked
      And the "budget_inputs" checkbox should not be checked
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Inputs" within ".section_nav"
      And I fill in "activity[classifications][coding_budget_cost_categorization][3]" with "100"
      And I fill in "activity[classifications][coding_spend_cost_categorization][3]" with "100"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      When I run delayed jobs
        And I refresh the page
      Then the "spend_inputs" checkbox should be checked
        And the "budget_inputs" checkbox should be checked

    Scenario: Reporter can follow classification workflow for activity
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
        And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
        And I follow "activity1"
      When I press "Save & Add Locations >"
        And I press "Save & Add Purposes >"
        And I press "Save & Add Inputs >"
        And I press "Save & Add Targets >"
        And I press "Save & Go to Overview >"
      Then I should see "Projects & Activities" within "h1"

    Scenario: Reporter can follow other costs workflow for other cost
      Given an other cost exists with name: "OC1", data_response: the data_response, project: the project
      When I follow "Projects"
        And I follow "OC1"
      When I press "Save & Add Locations >"
        And I press "Save & Go to Overview >"
      Then I should see "Projects & Activities" within "h1"
