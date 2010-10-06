Feature: NGO/donor can enter a code breakdown for each activity 
  In order to increase the quality of information reported
  As a NGO/Donor
  I want to be able to break down activities into individual codes

Background:
  Given the following organizations 
    | name             |
    | WHO              |
    | UNAIDS           |
  Given the following reporters 
     | name         | organization |
     | who_user     | WHO          |
  Given a data request with title "Req1" from "UNAIDS"
  Given a data response to "Req1" by "WHO"
  Given a project with name "TB Treatment Project" and an existing response
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project" and an existing response
  Given a refactor_me_please current_data_response for user "who_user"
  Given I am signed in as "who_user"

@green
Scenario: See a breakdown for an activity
  When I go to the classifications page
  And I follow "Classify"
  Then I should see "TB Drugs procurement"
  And I should see "Budget by Coding"
  And I should see "Budget by District"
  And I should see "Budget Cost Categorization"
  And I should see "Expenditure by Coding"
  And I should see "Expenditure by District"
  And I should see "Expenditure Cost Categorization"
  And I should see "Providing Technical Assistance"
  
@green
Scenario: See both budget for an activity classification
  When I go to the classifications page
  And I follow "Classify"
  Then I should be on the budget classification page for "TB Drugs procurement"
  And I should see "Budget"
  And I should see the "Budget" tab is active

@green
Scenario: enter budget for an activity
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"

@javascript
@slow
@green
Scenario: enter expenditure for an activity
  Given I am on the budget classification page for "TB Drugs procurement"
  And I follow "Expenditure by Coding"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00" within ".tab4"
  And I press "Save" within ".tab4"
  Then I should see "Activity classification was successfully updated."
  And I follow "Expenditure by Coding"
  #Then wait a few moments
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab4" should contain "1,234,567.00"

@green
Scenario: Bug: enter budget for an activity, save, shown with xx,xxx.yy number formatting, save again, ensure number is not nerfed. 
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"
  And I press "Save"
  Then the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"

@slow
@green
Scenario Outline: enter percentage for an activity budget classification
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in the percentage for "Human Resources For Health" with "<amount>"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the percentage for "Human Resources For Health" field should equal "<amount2>"
  Examples:
    | amount | amount2 |
    | 25     | 25.0    |
    | 50.1   | 50.1    |
    | 95.6   | 95.6    |

@green
Scenario: Cannot approve an Activity
  When I go to the classifications page
  And I follow "Classify"
  Then I should not see "Approved?"

@javascript
@slow
@green
Scenario: Use budget by coding for expenditure by coding (and change existing budget coding to see if the spend coding also changes)
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00" within ".tab1"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab1" should contain "1,234,567.00"
  When I check "Use budget codings for Expenditure?"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "Expenditure by Coding"
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  Then the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab4" should contain "1,234,567.00"
  When I follow "Budget by Coding"
  And I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "7654321.00" within ".tab1"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab1" should contain "7,654,321.00"
  And I follow "Expenditure by Coding"
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab4" should contain "7,654,321.00"

@javascript
@slow
@green
Scenario: Use budget by district for expenditure by district
  Given location "Burera" for activity "TB Drugs procurement"
  And I am on the budget classification page for "TB Drugs procurement"
  And I follow "Budget by District"
  And I fill in "Burera" with "1234567.00" within ".tab2"
  When I press "Save" within ".tab2"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  When I follow "Budget by District"
  Then the "Burera" field within ".tab2" should contain "1,234,567.00"
  When I check "Use budget codings for Expenditure?"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "Expenditure by District"
  And I wait until "Burera" is visible
  Then the "Burera" field within ".tab5" should contain "1,234,567.00"

@javascript
@slow
@green
Scenario: Use budget by cost categorization for expenditure by cost categorization
  And I am on the budget classification page for "TB Drugs procurement"
  And I follow "Budget Cost Categorization"
  And I fill in "Drugs, Commodities & Consumables" with "1234567.00" within ".tab3"
  When I press "Save" within ".tab3"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  When I follow "Budget Cost Categorization"
  Then the "Drugs, Commodities & Consumables" field within ".tab3" should contain "1,234,567.00"
  When I check "Use budget codings for Expenditure?"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "Expenditure Cost Categorization"
  And I wait until "Drugs, Commodities \& Consumables" is visible
  Then the "Drugs, Commodities & Consumables" field within ".tab6" should contain "1,234,567.00"
