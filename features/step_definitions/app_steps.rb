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

Given /^I am signed in as a reporter$/ do
  Given 'a reporter "Frank" with email "frank@f.com" and password "password"'
  When 'I go to the login page'
  When 'I fill in "Username or email" with "Frank"'
  And 'I fill in "Password" with "password"'
  And 'I press "Submit"'
end

Given /^an organization with name "([^"]*)"$/ do |name|
  @organization = Factory.create(:organization, :name => name)
end

Given /^a reporter "([^"]*)" in organization "([^"]*)"$/ do |reporter, org_name|
  @organization = Factory.create(:organization, :name => org_name)
  Given 'a reporter "#{reporter}" with email "frank@f.com" and password "password"'
  @user.organization = @organization
end

