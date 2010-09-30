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
  And I should see "Budget"
  And I should see "Budget by District"
  And I should see "Budget Cost Categorization"
  And I should see "Spend"
  And I should see "Spend by District"
  And I should see "Spend Cost Categorization"
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
  And I follow "Spend"
  When I fill in "Providing Technical Assistance, Improving Planning, Building Capacity, Strengthening Systems" with "1234567.00" within ".tab4"
  And I press "Save" within ".tab4"
  Then I should see "Activity classification was successfully updated."
  And I follow "Spend"
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
