Feature: Admin can manage organizations
  In order to save time and avoid user revolt
  As an admin
  I want to be able to manage organizations

  Background:
    Given now is "01-01-2011 21:30:00 +0000"
    Given an organization exists with name: "org1", raw_type: "Donor", fosaid: "111"
    And a data_request exists with title: "Req1", organization: the organization
    And an admin exists with email: "sysadmin@hrtapp.com", organization: the organization
    And a location exists with short_display: "All"
    Given now is "01-06-2011 21:30:00 +0000"
    And an organization exists with name: "org2", raw_type: "Ngo", fosaid: "222", location: the location
    And a reporter exists with email: "org2_user@hrtapp.com", organization: the organization
    Given now is "12-12-2011 08:30:00 +0000"
    And I am signed in as "sysadmin@hrtapp.com"
    And I follow "Organizations"

  Scenario: Admin can CRUD organizations
    Given I follow "Create Organization"
    And I fill in "Name" with "Organization name"
    And I select "Bilateral" from "Raw Type"
    And I fill in "Implementer Type" with "Implementer"
    And I fill in "Funder Type" with "Donor"
    And I fill in "Fosaid" with "123"
    And I fill in "Contact Name" with "Pink"
    And I fill in "Contact Position" with "The man"
    And I fill in "Phone Number" with "34234234"
    And I fill in "Office Number" with "34234234"
    And I fill in "Office Location" with "Japan"
    And I press "Create organization"
    Then I should see "Organization was successfully created"
    And the "Name" field should contain "Organization name"
    And the "Fosaid" field should contain "123"
    And the "Raw Type" field should contain "Bilateral"
    And the "Implementer Type" field should contain "Implementer"
    And the "Funder Type" field should contain "Donor"
    And the "Contact Name" field should contain "Pink"
    And the "Contact Position" field should contain "The man"
    And the "Phone Number" field should contain "34234234"
    And the "Office Number" field should contain "34234234"
    And the "Office Location" field should contain "Japan"
    When I fill in "Name" with "My new organization"
    And I press "Update organization"
    Then I should see "Organization was successfully updated"
    And the "Name" field should contain "My new organization"
    When I follow "Delete this Organization"
    Then I should see "Organization was successfully destroyed"
    And I should not see "Organization name"
    And I should not see "My new organization"

  # This spec is throwing a java.util.ConcurrentModificationException on some
  # environments (usually locally)
  # Potentially fixed in JRuby 1.6.4 ?  http://jruby.org/2011/08/22/jruby-1-6-4.html
  # Also noted here: http://jira.codehaus.org/browse/JRUBY-5209?page=com.atlassian.streams.streams-jira-plugin%3Aactivity-stream-issue-tab#issue-tabs
  @javascript @wip
  Scenario Outline: Merge duplicate organizations
    Given an organization exists with name: "org3"
    And I follow "Fix duplicate organizations"
    And I select "<duplicate>" from "Potential problem organization (duplicate)"
    And I select "<target>" from "Replacement organization"
    And I press "Replace"
    Then I should see "<message>"

    Examples:
      | duplicate      | target         | message                                               |
      | Org3 - 0 users | Org3 - 0 users | Same organizations for duplicate and target selected. |
      | Org3 - 0 users | Org2 - 1 user  | Organizations successfully merged.                    |

  @javascript @wip
  Scenario Outline: Merge duplicate organizations (with JS)
    Given an organization exists with name: "org3"
    And I follow "Fix duplicate organizations"
    And I select "<duplicate>" from "Potential problem organization (duplicate)"
    And I select "<target>" from "Replacement organization"
    And I should see "Organization: <duplicate_box>" within "#duplicate"
    And I should see "Organization: <target_box>" within "#target"
    And I press "Replace"
    And I confirm the popup dialog
    Then I should see "<message>"
    And "<removed_duplicates>" should not be an option for "Potential problem organization (duplicate)"

    Examples:
      | duplicate      | target         | duplicate_box  | target_box     | message                                               | remaining_duplicates |
      | Org3 - 0 users | Org3 - 0 users | Org3 | Org3 | Same organizations for duplicate and target selected. |                      |
      | Org3 - 0 users | Org2 - 1 user  | Org3 | Org2 | Organizations successfully merged.                    | org1                 |

  Scenario Outline: An admin can sort organizations
    And I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text1>"
    And column "<column>" row "2" should have text "<text2>"
    When I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text2>"
    And column "<column>" row "2" should have text "<text1>"

    Examples:
      | column_name  | column | text1 | text2 |
      | Organization | 1      | org2  | org1  |
      | Type         | 4      | Donor | Ngo   |

  Scenario: An admin can search organizations
    Then I should see "org1"
    And I should see "org2"
    And I fill in "query" with "org1"
    And I press "Search"
    And I should see "org1" within "table"
    And I should not see "org2" within "table"

  Scenario: admin can see available filters
    Then I should see "Reporting" within a link in the filters list
    And I should see "Not Yet Started" within a link in the filters list
    And I should see "Started" within a link in the filters list
    And I should see "Submitted" within a link in the filters list
    And I should see "Rejected" within a link in the filters list
    And I should see "Accepted" within a link in the filters list
    And I should see "Non-Reporting" within a link in the filters list
    And I should see "All" within a link in the filters list

  Scenario: An admin can filter organizations by response status
    Given the latest response for "org2" is submitted
    Then I follow "Submitted"
    Then I should not see "org1" within "table"
    And I should see "org2" within "table"

  Scenario: An admin sees only reporting orgs by default
    Given an organization exists with name: "some clinic", raw_type: "Clinic/Cabinet Medical"
    And I follow "Organizations"
    Then I should not see "some clinic"

  Scenario: An admin can view non-reporting orgs
    Given an organization exists with name: "some clinic", raw_type: "Clinic/Cabinet Medical"
    When I follow "Non-Reporting"
    Then I should see "some clinic"

  Scenario: An admin can sort by created at
    When I follow "Created" within the table heading
    Then I should see "org2" within a link in the 1st row of the table

  Scenario: can see correct listing columns
    When I follow "Sign Out"
    Given now is "12-12-2011 08:31:00 +0000"
    And I am signed in as "org2_user@hrtapp.com"
    And I follow "Sign Out"
    Given now is "12-12-2011 08:32:00 +0000"
    And I am signed in as "sysadmin@hrtapp.com"
    When I follow "Organizations"
    Then I should see "Organization" within the table heading
    And I should see "Last Login By" within the table heading
    And I should see "Last Login At" within the table heading
    And I should see "Type" within the table heading
    And I should see "FOSAID" within the table heading
    And I should see "Location" within the table heading
    And I should see "Created" within the table heading
    And I should see "Status" within the table heading
    And I should see "org2" within a link in the 2nd row of the table
    And I should see "Some Reporter" within a link in the 2nd row of the table
    And I should see "12 Dec '11 08:31" within the 2nd row of the table
    And I should see "Ngo" within the 2nd row of the table
    And I should see "222" within the 2nd row of the table
    And I should see "All" within the 2nd row of the table
    And I should see "01 Jun '11" within the 2nd row of the table
    And I should see "Not Yet Started" within the 2nd row of the table

  Scenario: An admin can see an organization's users
    When I follow "Edit" within a link in the 1st row of the table
    Then I should see "Users" within "h2"
    And I should see "sysadmin@hrtapp.com"

