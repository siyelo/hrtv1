@wip
Feature: Reporter can manage projects
  In order to track information
  As a reporter
  I want to be able to manage my commodities
  
  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1"
      And an organization exists with name: "organization2"
      And a data_response exists with data_request: the data_request, organization: the organization
      And a reporter exists with username: "reporter", organization: the organization
      And a cost_category_code exists with short_display: "Incentives"
      And I am signed in as "reporter"
      And I follow "data_request1"
      And I press "Update Response"
      And I follow "Commodities"



    Scenario: Reporter can CRUD commodities
      When I follow "Create Commodity"
        And I select "Incentives" from "commodity_commodity_type"
        And I fill in "commodity_description" with "stuff to make people work"
        And I fill in "commodity_unit_cost" with "2.5"
        And I fill in "commodity_quantity" with "3"
        And I press "commodity_submit"
      Then I should see "Incentives"
        And I should see "stuff to make people work"
        And I should see "3"
        And I should see "2.5"
        And I should see "7.5"

      When I follow "Edit"
        And I fill in "commodity_description" with "Commodity1"
        And I fill in "commodity_unit_cost" with "4"
        And I fill in "commodity_quantity" with "30"
        And I select "Incentives" from "commodity_commodity_type"
        And I press "commodity_submit"
      Then I should see "Commodity1"
        And I should see "Incentives"
        And I should see "30"
        And I should see "4"
        And I should see "Commodity was successfully updated"
      
      When I follow "X"
      Then I should see "Commodity was successfully destroyed"
        And I should not see "Commodity1"


    Scenario: Adding malformed CSV file doesn't throw exception
      When I attach the file "spec/fixtures/malformed.csv" to "File"
        And I press "Upload and Import"
      Then I should see "Your CSV file does not seem to be properly formatted"


    Scenario: Reporter can upload commodities
      When I attach the file "spec/fixtures/commodity.csv" to "File"
        And I press "Upload and Import"
      Then wait a few moments


    Scenario: Reporter can see error if no csv file is not attached for upload
      When I press "Upload and Import"
      Then I should see "Please select a file to upload"


    Scenario: Reporter can see error when invalid csv file is attached for upload and download template
      When I attach the file "spec/fixtures/invalid.csv" to "File"
        And I press "Upload and Import"
      Then I should see "Wrong fields mapping. Please download the CSV template"

      When I follow "Download template"
      Then I should see "commodity_type,description,unit_cost,quantity"
