Feature: Admin can manage data responses
  In order to reduce costs
  As an admin
  I want to be able to manage data responses

  Background:
    Given an organization exists with name: "GoR"
      And a data_request exists with title: "Req1", organization: the organization
      And a reporter exists with username: "reporter", organization: the organization
      And an organization exists with name: "UNDP", raw_type: "Agencies"
      And a data_response exists with data_request: the data_request, organization: the organization
      And I am signed in as a sysadmin

    Scenario: Manage data responses
      When I follow "Review Organization Expenditures and Budgets"
       And I follow "Empty"
      Then I should see "UNDP"

      When I follow "Delete"
      And I press "Delete"
      Then I should see "Data response was successfully deleted"
      And I should not see "UNDP"

    @javascript
    Scenario: Manage data responses (with JS)
      When I follow "Review Organization Expenditures and Budgets"
       And I follow "Empty"
       And I confirm the popup dialog
       And I follow "Delete"
      Then I should not see "UNDP"
