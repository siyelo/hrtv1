Feature: In order to review data responses
  As a reporter
  I want to be able to manage data responses

@admin_data_responses
Scenario: Manage data responses
    Given the following organizations 
      | name   | raw_type |
      # empty data response: Agencies, Donors, Implementer, Implementers, International NGO
      | UNDP   | Agencies |
      | GoR    |          |
    Given the following reporters 
       | name         | organization |
       | undp_user    | UNDP         |
    Given a data request with title "Req1" from "GoR"
    Given a data response to "Req1" by "UNDP" 
    Given I am signed in as an admin
    When I follow "Dashboard"
    And I follow "Review data responses" within ".admin_dashboard"
    Then I should see "UNDP"
    When I follow "Delete"
    And I press "Delete"
    Then I should see "Data response was successfully deleted"
    Then I should not see "UNDP"

@admin_data_responses @javascript
Scenario: Manage data responses (with JS)
    Given the following organizations 
      | name   | raw_type |
      | UNDP   | Agencies |
      | GoR    |          |
    Given the following reporters 
       | name         | organization |
       | undp_user    | UNDP         |
    Given a data request with title "Req1" from "GoR"
    Given a data response to "Req1" by "UNDP" 
    Given I am signed in as an admin
    When I follow "Dashboard"
    And I follow "Review data responses" within ".admin_dashboard"
    Then I should see "UNDP"
    When I will confirm a js popup
    And I follow "Delete"
    Then I should not see "UNDP"
