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



