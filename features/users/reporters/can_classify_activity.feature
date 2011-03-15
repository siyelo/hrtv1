Feature: Reporter can enter a code breakdown for each activity
  In order to increase the quality of information reported
  As a reporter
  I want to be able to break down activities into individual codes

Background:
  Given an organization exists with name: "Organization1"
  And a data_request exists with title: "Request"
  And an organization exists with name: "Organization2"
  And a data_response exists with data_request: the data_request, organization: the organization
  And a reporter exists with username: "reporter", organization: the organization, current_data_response: the data_response
  And a project exists with name: "Project", data_response: the data_response
  And an activity exists with name: "Activity", data_response: the data_response, project: the project
  And I am signed in as "reporter"

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
  And a mtef_code "mtef1" exists with short_display: "mtef1"
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

  # Wait for first tab to be loaded
  Given I am on the budget classification page for "Activity"
  Then wait a few moments

@reporters @classify_activity @javascript
Scenario: enter budget for an activity (don't see flash errors)
  When I fill in "mtef1" with "5000000.00"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "Activity"
  And the "mtef1" field should contain "5,000,000.00"

@reporters @classify_activity @javascript
Scenario: enter budget for an activity (see flash errors)
  When I fill in "mtef1" with "1234567.00"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "Activity"
  And the "mtef1" field should contain "1,234,567.00"
  And I should see "We're sorry, when we added up your Budget by Purposes classifications, they equaled 1,234,567.00 but the budget is 5,000,000.00 (5,000,000.00 - 1,234,567.00 = 3,765,433.00, which is ~75.31%). The total classified should add up to 5,000,000.00." within "#flashes"
  And I should see "We're sorry, when we added up your Budget by Purposes classifications, they equaled 1,234,567.00 but the budget is 5,000,000.00 (5,000,000.00 - 1,234,567.00 = 3,765,433.00, which is ~75.31%). The total classified should add up to 5,000,000.00." within ".tab1 .flashes .error"

@reporters @classify_activity @javascript
Scenario: enter expenditure for an activity
  When I follow "Purposes" within the expenditure coding tab
  And I fill in "mtef1" with "1234567.00" within ".tab4"
  And I press "Save" within ".tab4"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I follow "Purposes" within the expenditure coding tab
  Then wait a few moments
  And the "mtef1" field within ".tab4" should contain "1,234,567.00"

@reporters @classify_activity @javascript
Scenario: Bug: enter budget for an activity, save, shown with xx,xxx.yy number formatting, save again, ensure number is not nerfed.
  When I fill in "mtef1" with "1234567.00"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "Activity"
  And the "mtef1" field should contain "1,234,567.00"
  And I press "Save"
  Then wait a few moments
  And the "mtef1" field should contain "1,234,567.00"

@reporters @classify_activity @javascript
Scenario Outline: enter percentage for an activity budget classification
  When I fill in "mtef1" percentage field with "<amount>"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "Activity"
  And the "mtef1" percentage field should contain "<amount2>"
  Examples:
    | amount | amount2 |
    | 25     | 25.0    |
    | 50.1   | 50.1    |
    | 95.6   | 95.6    |

@reporters @classify_activity @javascript
Scenario: Use budget by district for expenditure by district
  Given a location exists with short_display: "Location1"
  And the location is one of the activity's locations
  And I am on the budget classification page for "Activity"
  And I follow "Locations" within the budget districts tab
  And I fill in "Location1" with "1234567.00" within ".tab2"
  When I press "Save" within ".tab2"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "Activity"
  When I follow "Locations" within the budget districts tab
  Then the "Location1" field within ".tab2" should contain "1,234,567.00"
  When I confirm the popup dialog
  Then wait a few moments
  And I follow "Click here to copy the budget classifications below to the expenditure District tab"
  And I go to the budget classification page for "Activity"
  And I follow "Locations" within the expenditure districts tab
  Then wait a few moments
  Then the "Location1" field within ".tab5" should contain "1,481,480.40"

@reporters @classify_activity @javascript
Scenario: Use budget by cost categorization for expenditure by cost categorization
  When I follow "Inputs" within the budget cost categorization tab
  And I fill in "cost_category1" with "1234567.00" within ".tab3"
  When I press "Save" within ".tab3"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "Activity"
  When I follow "Inputs" within the budget cost categorization tab
  And the "cost_category1" field within ".tab3" should contain "1,234,567.00"
  And I confirm the popup dialog
  And I follow "Click here to copy the budget classifications below to the expenditure Cost Category tab"
  And I go to the budget classification page for "Activity"
  And I follow "Inputs" within the expenditure cost categorization tab
  Then wait a few moments
  Then the "cost_category1" field within ".tab6" should contain "1,481,480.40"

@reporters @classify_activity @javascript
Scenario: Use budget by coding for expenditure by coding (deep coding in different roots, using percentages)
  When I click element ".tab1 ul.activity_tree > li:nth-child(1) > .collapsed"
  And I click element ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > .collapsed"
  And I fill in "%" with "10" within ".tab1 ul.activity_tree > li:nth-child(1)"
  And I fill in "%" with "5" within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)"
  And I fill in "%" with "1" within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)"

  And I click element ".tab1 ul.activity_tree > li:nth-child(2) > .collapsed"
  And I click element ".tab1 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > .collapsed"
  And I fill in "%" with "10" within ".tab1 ul.activity_tree > li:nth-child(2)"
  And I fill in "%" with "5" within ".tab1 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1)"
  And I fill in "%" with "1" within ".tab1 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > ul > li:nth-child(1)"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "Activity"

  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1)" should contain "500,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "250,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(2)" should contain "500,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1)" should contain "250,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"
  When I confirm the popup dialog
  And I follow "Click here to copy the budget classifications below to the expenditure Coding tab"
  And I go to the budget classification page for "Activity"
  And I follow "Purposes" within the expenditure coding tab
  Then wait a few moments
  Then the cached field within ".tab4 ul.activity_tree > li:nth-child(1)" should contain "600,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "300,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(2)" should contain "600,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1)" should contain "300,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"

@reporters @classify_activity @javascript
Scenario: Use budget by coding for expenditure by coding (deep coding in same root omitting the parents, using percentages)
  When I click element ".tab1 ul.activity_tree > li:nth-child(1) > .collapsed"
  And I click element ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > .collapsed"
  And I fill in "%" with "1" within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)"
  And I fill in "%" with "2" within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "Activity"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1)" should contain "150,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "150,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "100,000.00"
  When I confirm the popup dialog
  And I follow "Click here to copy the budget classifications below to the expenditure Coding tab"
  And I go to the budget classification page for "Activity"
  And I follow "Purposes" within the expenditure coding tab
  Then wait a few moments
  Then the cached field within ".tab4 ul.activity_tree > li:nth-child(1)" should contain "180,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "180,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "120,000.00"

  #### change coding and see if budget codings are changed
  When I follow "Purposes" within the budget coding tab
  And I fill in "%" with "2" within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)"
  And I press "Save"
  Then wait a few moments
  Then I should see "We're sorry, when we added up your Budget by Purposes classifications, they equaled 200,000.00 but the budget is 5,000,000.00 (5,000,000.00 - 200,000.00 = 4,800,000.00, which is ~96.00%). The total classified should add up to 5,000,000.00. You need to classify the total amount 3 times, in the coding, districts, and cost categories tabs."
  And I go to the budget classification page for "Activity"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1)" should contain "200,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "200,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "100,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "100,000.00"

  ### change  budget and spend for activity
  When I follow "Activities"
  And I follow "Edit"
  And I fill in "Budget" with "1000"
  And I fill in "Spent" with "2000"
  And I press "Update Activity"
  And I go to the budget classification page for "Activity"
  Then the cached field within ".tab1 ul.activity_tree > li:nth-child(1)" should contain "40.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "40.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "20.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "20.00"

