Feature: Reporter can see dashboard
  In order to improve data quality
  A reporter can see prompt to review data, when Request is in final review stage
  
  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And I am signed in as "reporter@hrtapp.com"
      
  Scenario: Prompted to review incomplete data    
    Then I should see "Empty / Not Started"