Feature: Admin can manage data requests
  In order to collect data in the system
  As a admin
  I want to be able to manage data requests

  Background:
    Given an organization exists with name: "org1"
    And a data_request exists with organization: the organization
    And a sysadmin exists with username: "admin", organization: the organization
    And I am signed in as "admin"

    Scenario: Admin can CRUD data requests
      When I follow "Requests"
       And I follow "Create Data Request"
       And I select "org1" from "Organization"
       And I fill in "Title" with "My data response title"
       And I fill in "Due date" with "2010-09-01"
       And I fill in "Start date" with "2010-01-01"
       And I fill in "End date" with "2011-01-01"
       And I press "Create request"
      Then I should see "Request was successfully created"
       And I should see "My data response title"
       And I should see "org1"

      When I follow "Edit"
       And I fill in "Title" with "My new data response title"
       And I press "Update request"
      Then I should see "Request was successfully updated"
       And I should see "My new data response title"

      When I follow "Delete"
      Then I should see "Request was successfully deleted"
       And I should not see "My data response title"


    Scenario Outline: See errors when creating data request
      When I follow "Requests"
       And I follow "Create Data Request"
       And I select "<organization>" from "Organization"
       And I fill in "Title" with "<title>"
       And I fill in "Start date" with "<start_date>"
       And I fill in "End date" with "<end_date>"
       And I fill in "Due date" with "<due_date>"
       And I press "Create request"
      Then I should see "<message>"

      Examples:
        | organization | title | due_date   | start_date | end_date   | message                              | 
        | org1         | title | 2010-09-01 | 2010-01-01 | 2011-01-01 | Request was successfully created     | 
        |              | title | 2010-09-01 | 2010-01-01 | 2011-01-01 | Organization can't be blank         | 
        | org1         |       | 2010-09-01 | 2010-01-01 | 2011-01-01 | Title can't be blank         | 
        | org1         |       |            | 2010-01-01 | 2011-01-01 | Due date can't be blank         | 
        | org1         |       | 123        | 2010-01-01 | 2011-01-01 | Due date is not a valid date    | 
        | org1         | title | 2010-09-01 |            | 2011-01-01 | Start date can't be blank         | 
        | org1         | title | 2010-09-01 | 123        | 2011-01-01 | Start date is not a valid date    | 
        | org1         | title | 2010-09-01 | 2010-01-01 | 123        | End date is not a valid date    | 
        | org1         | title | 2010-09-01 | 2010-01-01 |            | End date can't be blank         | 
        | org1         | title | 2010-09-01 | 2011-01-01 | 2010-01-01 | Start date must come before End date | 

    Scenario: To expedite the review process, a sysadmin can change a Request to "Final Review" status
      When I follow "Requests"
       And I follow "Edit"
       And I check "Final review"
       And I press "Update request"
      Then I should see "Request was successfully updated."
