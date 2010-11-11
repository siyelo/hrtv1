#http://bjeanes.com/2010/09/19/selector-free-cucumber-scenarios

When /^(.*) within ([^:"]+)$/ do |step, scope|
  with_scope(selector_for(scope)) do
    When step
  end
end

# Multi-line version of above
When /^(.*) within ([^:"]+):$/ do |step, scope, table_or_string|
  with_scope(selector_for(scope)) do
    When "#{step}:", table_or_string
  end
end

When /^I will confirm a js popup$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
end


Then /^the cached field "([^"]*)" should contain "([^"]*)"$/ do |selector, value|
  find(selector).value.should == value
end

Then /^the cached field "([^"]*)" within "([^"]*)" should contain "([^"]*)"$/ do |field, selector, value|
  within(selector) do
    find(field).value.should == value
  end
end

class Capybara::XPath
  class << self
    def element(locator)
      append("//*[normalize-space(text())=#{s(locator)}]")
    end
  end
end

When /^I click element "([^"]*)"$/ do |selector|
  find(selector).click
end

Then /^the "([^"]*)" text should be "([^"]*)"$/ do |label, value|
  find_field(label).text.should == value
end

Then /^the "([^"]*)" text should not be "([^"]*)"$/ do |label, value|
  find_field(label).text.should_not == value
end

Then /^the "([^"]*)" text should match "([^"]*)"$/ do |label, value|
  find_field(label).text.should match(value)
end
