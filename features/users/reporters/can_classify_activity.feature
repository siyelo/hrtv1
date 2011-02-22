Feature: Reporter can enter a code breakdown for each activity
  In order to increase the quality of information reported
  As a reporter
  I want to be able to break down activities into individual codes

Background:
  Given a basic org + reporter profile, with data response, signed in

@reporter_activity_breakdown
Scenario: See a breakdown for an activity
  When I go to the activities page
  And I follow "Classify"
  Then I should see "TB Drugs procurement"
  And I should see "Coding" within the budget coding tab
  And I should see "District" within the budget districts tab
  And I should see "Categorization" within the budget cost categorization tab
  And I should see "Coding" within the expenditure coding tab
  And I should see "District" within the expenditure districts tab
  And I should see "Cost Categorization" within the expenditure cost categorization tab
  And I should see "Providing Technical Assistance"

@reporter_activity_breakdown
Scenario: See both budget for an activity classification
  When I go to the activities page
  And I follow "Classify"
  Then I should be on the budget classification page for "TB Drugs procurement"
  And I should see "Coding"
  And I should see the "Coding" tab is active

@reporter_activity_breakdown
Scenario: enter budget for an activity (don't see flash errors)
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "5000000.00"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "5,000,000.00"
  And I should not see "We're sorry, when we added up"

@reporter_activity_breakdown
Scenario: enter budget for an activity (see flash errors)
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"
  And I should see "We're sorry, when we added up your Budget Coding classifications, they equaled 1,234,567.00 but the budget is 5,000,000.00 (5,000,000.00 - 1,234,567.00 = 3,765,433.00, which is ~75.31%). The total classified should add up to 5,000,000.00." within "#flashes"
  And I should see "We're sorry, when we added up your Budget Coding classifications, they equaled 1,234,567.00 but the budget is 5,000,000.00 (5,000,000.00 - 1,234,567.00 = 3,765,433.00, which is ~75.31%). The total classified should add up to 5,000,000.00." within ".tab1 .flashes .error"

@reporter_activity_breakdown @javascript
Scenario: enter expenditure for an activity
  Given I am on the budget classification page for "TB Drugs procurement"
  And I follow "Coding" within the expenditure coding tab
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00" within ".tab4"
  And I press "Save" within ".tab4"
  Then wait a few moments
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I follow "Coding" within the expenditure coding tab
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab4" should contain "1,234,567.00"

@reporter_activity_breakdown
Scenario: Bug: enter budget for an activity, save, shown with xx,xxx.yy number formatting, save again, ensure number is not nerfed.
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"
  And I press "Save"
  Then the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"

@reporter_activity_breakdown
Scenario Outline: enter percentage for an activity budget classification
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in the percentage for "Human Resources For Health" with "<amount>"
  And I press "Save"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the percentage for "Human Resources For Health" field should equal "<amount2>"
  Examples:
    | amount | amount2 |
    | 25     | 25.0    |
    | 50.1   | 50.1    |
    | 95.6   | 95.6    |

@reporter_activity_breakdown
Scenario: Cannot approve an Activity
  When I go to the activities page
  And I follow "Classify"
  Then I should not see "Approved?"

@reporter_activity_breakdown @javascript
Scenario: Use budget by district for expenditure by district
  Given location "Burera" for activity "TB Drugs procurement"
  And I am on the budget classification page for "TB Drugs procurement"
  And I follow "District" within the budget districts tab
  And I fill in "Burera" with "1234567.00" within ".tab2"
  When I press "Save" within ".tab2"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  When I follow "District" within the budget districts tab
  Then the "Burera" field within ".tab2" should contain "1,234,567.00"
  When I confirm the popup dialog
  Then wait a few moments
  And I follow "Click here to copy the budget classifications below to the expenditure District tab"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "District" within the expenditure districts tab
  And I wait until "Burera" is visible
  Then the "Burera" field within ".tab5" should contain "1,481,480.40"

@reporter_activity_breakdown @javascript
Scenario: Use budget by cost categorization for expenditure by cost categorization
  And I am on the budget classification page for "TB Drugs procurement"
  And I follow "Cost Categorization" within the budget cost categorization tab
  And I fill in "Drugs, Commodities & Consumables" with "1234567.00" within ".tab3"
  When I press "Save" within ".tab3"
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  When I follow "Cost Categorization" within the budget cost categorization tab
  And the "Drugs, Commodities & Consumables" field within ".tab3" should contain "1,234,567.00"
  And I confirm the popup dialog
  And I follow "Click here to copy the budget classifications below to the expenditure Cost Category tab"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "Cost Categorization" within the expenditure cost categorization tab
  And I wait until "Drugs, Commodities \& Consumables" is visible
  Then the "Drugs, Commodities & Consumables" field within ".tab6" should contain "1,481,480.40"

@reporter_activity_breakdown @javascript
@run
Scenario: Use budget by coding for expenditure by coding (deep coding in different roots, using percentages)
  Given I am on the budget classification page for "TB Drugs procurement"
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
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1)" should contain "500,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "250,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(2)" should contain "500,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1)" should contain "250,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"
  When I confirm the popup dialog
  And I follow "Click here to copy the budget classifications below to the expenditure Coding tab"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "Coding" within the expenditure coding tab
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  Then the cached field within ".tab4 ul.activity_tree > li:nth-child(1)" should contain "600,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "300,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(2)" should contain "600,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1)" should contain "300,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(2) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"

@reporter_activity_breakdown @javascript
Scenario: Use budget by coding for expenditure by coding (deep coding in same rootomitting the parents, using percentages)
  Given I am on the budget classification page for "TB Drugs procurement"
  When I click element ".tab1 ul.activity_tree > li:nth-child(1) > .collapsed"
  And I click element ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > .collapsed"
  And I fill in "%" with "1" within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)"
  And I fill in "%" with "2" within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)"
  And I press "Save"
  Then wait a few moments
  Then wait a few moments
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1)" should contain "150,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "150,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "50,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "100,000.00"
  When I confirm the popup dialog
  When I follow "Click here to copy the budget classifications below to the expenditure Coding tab"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "Coding" within the expenditure coding tab
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  Then the cached field within ".tab4 ul.activity_tree > li:nth-child(1)" should contain "180,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "180,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "60,000.00"
  And the cached field within ".tab4 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "120,000.00"
  #### change coding and see if budget codings are changed
  When I follow "Coding" within the budget coding tab
  And I fill in "%" with "2" within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)"
  And I press "Save"
  Then wait a few moments
  Then wait a few moments
  Then wait a few moments
  Then I should see "We're sorry, when we added up your Budget Coding classifications, they equaled 200,000.00 but the budget is 5,000,000.00 (5,000,000.00 - 200,000.00 = 4,800,000.00, which is ~96.00%). The total classified should add up to 5,000,000.00. You need to classify the total amount 3 times, in the coding, districts, and cost categories tabs."
  And I go to the budget classification page for "TB Drugs procurement"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1)" should contain "200,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "200,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "100,000.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "100,000.00"
  ### change  budget and spend for activity
  When I follow "Activities"
  And I follow "Edit"
  And I fill in "Total Budget GOR FY 10-11" with "1000"
  And I fill in "Total Spent GOR FY 09-10" with "2000"
  And I press "Update"
  And I go to the budget classification page for "TB Drugs procurement"
  Then the cached field within ".tab1 ul.activity_tree > li:nth-child(1)" should contain "40.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1)" should contain "40.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(1)" should contain "20.00"
  And the cached field within ".tab1 ul.activity_tree > li:nth-child(1) > ul > li:nth-child(1) > ul > li:nth-child(2)" should contain "20.00"
