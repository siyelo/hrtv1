Feature: Visitor can see homepage
  In order to be awesome
  As a visitor
  I want to be able to see a landing page

  Background:



    @visitors @homepage
    Scenario: See heading and login
      When I go to the home page
      Then I should see the visitors header
        And I should see the common footer
