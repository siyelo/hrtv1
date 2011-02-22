Feature: Reporter can derive classifications from sub implementers
  In order to save time entering values
  As a reporter
  I want to be able to use derived classifications from sub implementers

@classify_activity @javascript
Scenario: Use budget classifications derived from sub implementers
  Given a donor exists with name: "donor"
  And a ngo exists with name: "ngo"
  And a provider exists with name: "implementer"
  And a location exists with short_display: "Location1"
  And the location is one of the provider's locations

  And a data_request exists with organization: the donor
  And a data_response exists with organization: the ngo, data_request: the data_request
  And a project exists with data_response: the data_response
  And a funding_flow exists with data_response: the data_response, from: the donor, to: the ngo, budget: "10", spend: "10"
  And a funding_flow exists with data_response: the data_response, from: the ngo, to: the provider, budget: "7", spend: "7"
  And a activity exists with name: "Activity", budget: "100", spend: "100", provider: the ngo, data_response: the data_response
  And a sub_activity exists with activity: the activity, provider: the provider, data_response: the data_response, budget: "55"
  And the project is one of the activity's projects
  And the location is one of the activity's locations

  And a reporter exists with username: "reporter", organization: the ngo, current_data_response: the data_response
  And I am signed in as "reporter"
  And I am on the budget classification page for "Activity"
  And I follow "District" within the budget districts tab
  Then wait a few moments
  Given I confirm the popup dialog
  When I follow "Use budget classifications derived from sub implementers"
  And I go to the budget classification page for "Activity"
  And I follow "District" within the budget districts tab
  Then the "Location1" field within ".tab2" should contain "55.00"

@classify_activity @javascript
Scenario: Use spend classifications derived from sub implementers
  Given a donor exists with name: "donor"
  And a ngo exists with name: "ngo"
  And a provider exists with name: "implementer"
  And a location exists with short_display: "Location1"
  And the location is one of the provider's locations

  And a data_request exists with organization: the donor
  And a data_response exists with organization: the ngo, data_request: the data_request
  And a project exists with data_response: the data_response
  And a funding_flow exists with data_response: the data_response, from: the donor, to: the ngo, budget: "10", spend: "10"
  And a funding_flow exists with data_response: the data_response, from: the ngo, to: the provider, budget: "7", spend: "7"
  And a activity exists with name: "Activity", budget: "100", spend: "100", provider: the ngo, data_response: the data_response
  And a sub_activity exists with activity: the activity, provider: the provider, data_response: the data_response, spend: "56"
  And the project is one of the activity's projects
  And the location is one of the activity's locations

  And a reporter exists with username: "reporter", organization: the ngo, current_data_response: the data_response
  And I am signed in as "reporter"
  And I am on the budget classification page for "Activity"
  And I follow "District" within the expenditure districts tab
  Then wait a few moments
  Given I confirm the popup dialog
  When I follow "Use expenditure classifications derived from sub implementers"
  And I go to the budget classification page for "Activity"
  And I follow "District" within the expenditure districts tab
  Then wait a few moments
  Then the "Location1" field within ".tab5" should contain "56.00"
