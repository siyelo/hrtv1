@run
Feature: Reporter can see dashboard
  In order to improve data quality
  A reporter can see prompt to review data, when Request is in final review stage
  
  Background:
    Given an organization exists with name: "WHO"
    And a reporter exists with username: "some_user", organization: the organization
    And a data_request exists with title: "Req1", final_review: true, organization: the organization
   And a data_response exists with data_request: the data_request, organization: the organization
    
  Scenario: Prompted to review incomplete data
    And I am signed in as "some_user"
    When I go to the reporter dashboard page
    Then I should see "Your response is not yet complete for the Request: 'Req1'."
  
  Scenario: Prompted to review incomplete data for each incomplete request
    And a data_request exists with title: "Req2", final_review: true, organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And I am signed in as "some_user"
    When I go to the reporter dashboard page
    Then I should see "Your response is not yet complete for the Request: 'Req1'."
    And I should see "Your response is not yet complete for the Request: 'Req2'."
    
  Scenario: Prompted to review incomplete data for each incomplete request
    And a data_request exists with title: "Req2", final_review: false, organization: the organization
    And a data_response exists with data_request: the data_request, organization: the organization
    And I am signed in as "some_user"
    When I go to the reporter dashboard page
    Then I should see "Your response is not yet complete for the Request: 'Req1'."
    And I should not see "Your response is not yet complete for the Request: 'Req2'."

  # Dont display message for Requests that are in Final Review for some reason but aren't "current"