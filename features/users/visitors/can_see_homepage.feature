Feature: Visitor can see homepage
  In order to be awesome
  As a visitor
  I want to be able to see a landing page

Scenario: See heading and login
  When I go to the home page
  Then I should see "Have an account?"
  And I should see "Sign in"
  And I should see "Contact Us"
