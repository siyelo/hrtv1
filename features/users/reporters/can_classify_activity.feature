Feature: Reporter can enter a code breakdown for each activity
  In order to increase the quality of information reported
  As a reporter
  I want to be able to break down activities into individual codes

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
      And a mtef_code "mtef2" exists with short_display: "mtef2"

      # level 2
      And a mtef_code "mtef11" exists with short_display: "mtef11", parent: mtef_code "mtef1"
      And a mtef_code "mtef12" exists with short_display: "mtef12", parent: mtef_code "mtef1"
      And a mtef_code "mtef21" exists with short_display: "mtef21", parent: mtef_code "mtef2"
      And a mtef_code "mtef22" exists with short_display: "mtef22", parent: mtef_code "mtef2"

      # level 3
      And a mtef_code "mtef111" exists with short_display: "mtef111", parent: mtef_code "mtef11"
      And a mtef_code "mtef112" exists with short_display: "mtef112", parent: mtef_code "mtef11"
      And a mtef_code "mtef121" exists with short_display: "mtef121", parent: mtef_code "mtef12"
      And a mtef_code "mtef122" exists with short_display: "mtef122", parent: mtef_code "mtef12"
      And a mtef_code "mtef211" exists with short_display: "mtef111", parent: mtef_code "mtef21"
      And a mtef_code "mtef212" exists with short_display: "mtef112", parent: mtef_code "mtef21"
      And a mtef_code "mtef221" exists with short_display: "mtef121", parent: mtef_code "mtef22"
      And a mtef_code "mtef222" exists with short_display: "mtef122", parent: mtef_code "mtef22"

      # level 1
      And a cost_category_code exists with short_display: "cost_category1"
      And a service_level exists with short_display: "service_level1"

      And an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And an organization exists with name: "organization2"
      And a data_response exists with data_request: the data_request, organization: the organization
      And a reporter exists with username: "reporter", organization: the organization, current_response: the data_response
      And a project exists with name: "Project", data_response: the data_response
      And an activity exists with name: "Activity", data_response: the data_response, project: the project, description: "Activity description", budget: 5000000, spend: 6000000
      And I am signed in as "reporter"
      And I follow "data_request1"
      And I follow "Projects"
      And I follow "Activity description"



    Scenario: enter budget for an activity (don't see flash errors)
      When I follow "Budget"
        And I follow "Purposes"
        And I fill in "mtef1" with "5000000.00"
        And I press "Save"
      Then I should see "Activity classification was successfully updated."
        And I should be on the budget classification page for "Activity"
        And the "mtef1" field should contain "5,000,000.00"


    Scenario: enter budget for an activity (see flash errors)
      When I follow "Budget"
        And I follow "Purposes"
        And I fill in "mtef1" with "1234567.00"
        And I press "Save"
      Then I should not see "Activity classification was successfully updated."
        And I should be on the budget classification page for "Activity"
        And the "mtef1" field should contain "1,234,567.00"
        And I should see "We're sorry, when we added up your Budget by Purposes classifications, they equaled 1,234,567.00 but the Budget is 5,000,000.00 (5,000,000.00 - 1,234,567.00 = 3,765,433.00, which is ~75.31%). The total classified should add up to 5,000,000.00. Your Budget by Purposes classifications must be entered and the total must be equal to the Budget amount." within "#flashes"

    Scenario Outline: enter percentage for an activity budget classification
      When I follow "Budget"
        And I follow "Purposes"
        And I fill in "mtef1" percentage field with "<amount>"
        And I press "Save"
        Then I should not see "Activity classification was successfully updated."
        And I should see "We're sorry, when we added up your Budget by Purposes classifications"

        And the "mtef1" percentage field should contain "<amount2>"

        Examples:
          | amount | amount2 |
          | 25     | 25.0    |
          | 50.1   | 50.1    |
          | 95.6   | 95.6    |


    Scenario: enter expenditure for an activity
      When I follow "Expenditure"
        And I follow "Purposes"
        And I fill in "mtef1" with "1234567.00"
        And I press "Save"
        Then I should not see "Activity classification was successfully updated."
        And the "mtef1" field should contain "1,234,567.00"

        
    Scenario: Use budget by district for expenditure by district
      Given a location exists with short_display: "Location1"
        And the location is one of the activity's locations
        And I follow "Budget"
        And I follow "Locations"
        And I fill in "Location1" with "1234567.00"
      When I press "Save"
      Then I should not see "Activity classification was successfully updated."
        And the "Location1" field should contain "1,234,567.00"

      When I follow "Click here to copy the Budget splits below to the Expenditure Locations tab"
        And I follow "Expenditure"
        And I follow "Locations"
      Then the "Location1" field should contain "1,481,480.40"

    Scenario: Use budget by cost categorization for expenditure by cost categorization
      When I follow "Budget"
        And I follow "Inputs"
        And I fill in "cost_category1" with "1234567.00"
        And I press "Save"
      Then I should not see "Activity classification was successfully updated."
        And the "cost_category1" field should contain "1,234,567.00"

      When I follow "Click here to copy the Budget splits below to the Expenditure Inputs tab"
        And I follow "Expenditure"
        And I follow "Inputs"
      Then the "cost_category1" field should contain "1,481,480.40"

    Scenario: Use budget by service level for expenditure by service level
      When I follow "Budget"
        And I follow "Service Levels"
        And I fill in "service_level1" with "1234567.00"
        And I press "Save"
      Then I should not see "Activity classification was successfully updated."
        And I should be on the budget classification page for "Activity"
        And the "service_level1" field should contain "1,234,567.00"
      When I follow "Click here to copy the Budget splits below to the Expenditure Service Levels tab"
      Then the "service_level1" field should contain "1,481,480.40"


    Scenario: Use budget by coding for expenditure by coding (deep coding in different roots, using percentages)
      When I follow "Budget"
        And I follow "Purposes"
        And I fill in "%" with "10" within "ul.activity_tree > li:nth-child(1)"
        And I fill in "%" with "5" within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)"
        And I fill in "%" with "1" within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)"

        And I fill in "%" with "10" within "ul.activity_tree > li:nth-child(2)"
        And I fill in "%" with "5" within "ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1)"
        And I fill in "%" with "1" within "ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > ul > li:nth-child(1)"
        And I press "Save"
      Then I should not see "Activity classification was successfully updated."
        And I should be on the budget classification page for "Activity"
        And the cached field within "ul.activity_tree > li:nth-child(1)" should contain "500,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "250,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(2)" should contain "500,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1)" should contain "250,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"

      When I follow "Click here to copy the Budget splits below to the Expenditure Purposes tab"
        And I follow "Expenditure"
        And I follow "Purposes"
      Then the cached field within "ul.activity_tree > li:nth-child(1)" should contain "600,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "300,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(2)" should contain "600,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1)" should contain "300,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"


    Scenario: Use budget by coding for expenditure by coding (deep coding in same root omitting the parents, using percentages)
      When I press "Save & Classify >"
        And I follow "Budget"
        And I follow "Purposes"

        And I fill in "%" with "1" within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)"
        And I fill in "%" with "2" within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)"
        And I press "Save"
      Then I should not see "Activity classification was successfully updated."
        And the cached field within "ul.activity_tree > li:nth-child(1)" should contain "150,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "150,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "100,000.00"

      When I follow "Click here to copy the Budget splits below to the Expenditure Purposes tab"
        And I follow "Expenditure"
        And I follow "Purposes"
      Then the cached field within "ul.activity_tree > li:nth-child(1)" should contain "180,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "180,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "120,000.00"

      #### change coding and see if budget codings are changed
      When I follow "Budget"
        And I follow "Purposes"
        And I fill in "%" with "2" within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)"
        And I press "Save"
      Then I should see "We're sorry, when we added up your Budget by Purposes classifications, they equaled 200,000.00 but the Budget is 5,000,000.00 (5,000,000.00 - 200,000.00 = 4,800,000.00, which is ~96.00%). The total classified should add up to 5,000,000.00. Your Budget by Purposes classifications must be entered and the total must be equal to the Budget amount."
        And the cached field within "ul.activity_tree > li:nth-child(1)" should contain "200,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "200,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "100,000.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "100,000.00"

      ### change budget and spend for activity
      When I follow "Activity"
        And I fill in "Budget" with "1000"
        And I fill in "Expenditure" with "2000"
        And I press "Save & Classify >"
        And I follow "Budget"
        And I follow "Purposes"
      Then the cached field within "ul.activity_tree > li:nth-child(1)" should contain "40.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "40.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "20.00"
        And the cached field within "ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "20.00"
