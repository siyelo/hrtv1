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
  Given a project with name "TB Treatment Project" for request "Req1" and organization "WHO"
  Given an activity with name "TB Drugs procurement" in project "TB Treatment Project", request "Req1" and organization "WHO"
  Given I am signed in as "who_user"
  When I follow "Dashboard"
  And I follow "Edit"

Scenario: See a breakdown for an activity
  When I go to the activities page
  And I follow "Classify"
  Then I should see "TB Drugs procurement"
  And I should see "Coding" within "#tab1"
  And I should see "District" within "#tab2"
  And I should see "Categorization" within "#tab3"
  And I should see "Coding" within "#tab4"
  And I should see "District" within "#tab5"
  And I should see "Cost Categorization" within "#tab6"
  And I should see "Providing Technical Assistance"
  
Scenario: See both budget for an activity classification
  When I go to the activities page
  And I follow "Classify"
  Then I should be on the budget classification page for "TB Drugs procurement"
  And I should see "Coding"
  And I should see the "Coding" tab is active

Scenario: enter budget for an activity
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"

@javascript
Scenario: enter expenditure for an activity
  Given I am on the budget classification page for "TB Drugs procurement"
  And I follow "Coding" within "#tab4"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00" within ".tab4"
  And I press "Save" within ".tab4"
  Then I should see "Activity classification was successfully updated."
  And I follow "Coding" within "#tab4"
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab4" should contain "1,234,567.00"

Scenario: Bug: enter budget for an activity, save, shown with xx,xxx.yy number formatting, save again, ensure number is not nerfed. 
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"
  And I press "Save"
  Then the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field should contain "1,234,567.00"

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

Scenario: Cannot approve an Activity
  When I go to the activities page
  And I follow "Classify"
  Then I should not see "Approved?"

@javascript
Scenario: Use budget by coding for expenditure by coding (and change existing budget coding to see if the spend coding also changes)
  Given I am on the budget classification page for "TB Drugs procurement"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00" within ".tab1"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab1" should contain "1,234,567.00"
  When I check "Use budget codings for Expenditure?"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "Coding" within "#tab4"
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  Then the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab4" should contain "1,234,567.00"
  When I follow "Coding" within "#tab1"
  And I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "7654321.00" within ".tab1"
  And I press "Save"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab1" should contain "7,654,321.00"
  And I follow "Coding" within "#tab4"
  And I wait until "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" is visible
  And the "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" field within ".tab4" should contain "7,654,321.00"

@javascript
Scenario: Use budget by district for expenditure by district
  Given location "Burera" for activity "TB Drugs procurement"
  And I am on the budget classification page for "TB Drugs procurement"
  And I follow "District" within "#tab2"
  And I fill in "Burera" with "1234567.00" within ".tab2"
  When I press "Save" within ".tab2"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  When I follow "District" within "#tab2"
  Then the "Burera" field within ".tab2" should contain "1,234,567.00"
  When I check "Use budget codings for Expenditure?"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "District" within "#tab5"
  And I wait until "Burera" is visible
  Then the "Burera" field within ".tab5" should contain "1,234,567.00"

@javascript
Scenario: Use budget by cost categorization for expenditure by cost categorization
  And I am on the budget classification page for "TB Drugs procurement"
  And I follow "Cost Categorization" within "#tab3"
  And I fill in "Drugs, Commodities & Consumables" with "1234567.00" within ".tab3"
  When I press "Save" within ".tab3"
  Then I should see "Activity classification was successfully updated."
  And I should be on the budget classification page for "TB Drugs procurement"
  When I follow "Cost Categorization" within "#tab3"
  Then the "Drugs, Commodities & Consumables" field within ".tab3" should contain "1,234,567.00"
  When I check "Use budget codings for Expenditure?"
  And I go to the budget classification page for "TB Drugs procurement"
  And I follow "Cost Categorization" within "#tab6"
  And I wait until "Drugs, Commodities \& Consumables" is visible
  Then the "Drugs, Commodities & Consumables" field within ".tab6" should contain "1,234,567.00"
