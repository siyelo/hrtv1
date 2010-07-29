Given /^a project$/ do
  @project = Factory.create(:project)
end

Given /^a project with name "(.+)"$/ do |name|
  @project = Factory.create(:project, :name => name)
end

Given /^an activity with name "([^\"]*)"$/ do |name|
  @activity = Factory.create(:activity, :name => name)
end

Given /^an activity with name "([^\"]*)" in project "([^\"]*)"$/ do |name, project|
  @activity = Factory.create(:activity, :name => name, :projects => [Project.find_by_name(project)])
end

Given /^the following projects$/ do |table|
  table.hashes.each do |hash|
    Factory.create(:project, hash)
  end
end

Given /^a reporter "([^"]*)" with email "([^"]*)" and password "([^"]*)"$/ do | name, email, password|
  @user = Factory.create(:reporter, :username => name, :email => email, :password => password, :password_confirmation => password)
end

Given /^the following reporters$/ do |table|
  table.hashes.each do |hash|
    org  = Organization.find_by_name(hash.delete("organization"))
    username  = hash.delete("name")
    Factory.create(:reporter, { :username => username,
                                :organization_id => org.id
                                }.merge(hash) )
  end
end

Given /^I am signed in as "([^"]*)"$/ do |name|
  steps %Q{
    When I go to the login page
    When I fill in "Username or email" with "#{name}"
    And  I fill in "Password" with "password"
    And  I press "Submit"
  }
end

Given /^I am signed in as a reporter$/ do
  steps %Q{
    Given a reporter "Frank" with email "frank@f.com" and password "password"
    Given I am signed in as "Frank"
  }
end

Given /^an organization with name "([^"]*)"$/ do |name|
  @organization = Factory.create(:organization, :name => name)
end

Given /^the following organizations$/ do |table|
  table.hashes.each do |hash|
    Factory.create(:organization, hash)
  end
end

Given /^a reporter "([^"]*)" in organization "([^"]*)"$/ do |reporter, org_name|
  @organization = Factory.create(:organization, :name => org_name)
  steps %Q{
    Given a reporter "#{reporter}" with email "frank@f.com" and password "password"
  }
  @user.organization = @organization
end

Given /^the following funding flows$/ do |table|
  table.hashes.each do |hash|
    to_org   = Organization.find_by_name(hash.delete("to"))
    project  = Project.find_by_name(hash.delete("project"))
    from_org = Organization.find_by_name(hash.delete("from"))

    Factory.create(:funding_flow,  { :organization_id_to => to_org.id,  
                                      :project_id => project.id, 
                                      :organization_id_from => from_org.id
                                      }.merge(hash) )
  end
end

Then /^debug$/ do
  debugger # express the regexp above with the code you wish you had
end


Then /^I should see the "([^"]*)" tab is active$/ do |text|
  steps %Q{
    Then I should see "#{text}" within "li.selected"
  }
end

# a bit brittle
When /^I fill in the percentage for "Human Resources For Health" with "([^"]*)"$/ do |amount|
   steps %Q{ When I fill in "activity_budget_amounts_1_p" with "#{amount}"}
end

Then /^the percentage for "Human Resources For Health" field should contain "([^"]*)"$/ do |amount|
  steps %Q{ Then the "activity_budget_amounts_1_p" field should contain "#{amount}"}
end