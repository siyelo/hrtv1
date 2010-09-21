Given /^a project$/ do
  @project = Factory.create(:project)
end

Given /^a project with name "([^\"]*)"$/ do |name|
  @project = Factory.create(:project, :name => name)
end

# kill meeeee
Given /^a project with name "([^\"]*)" and an existing response$/ do |name|
  @project = Factory.create(:project, :name => name, :data_response => @data_response)
end

# kill meeeee
Given /^a project with name "([^\"]*)" in district "([^\"]*)" and an existing response$/ do |name, district|
  @project = Factory.create(:project, 
                            :name => name, 
                            :locations => [ Location.find_by_short_display district],
                            :data_response => @data_response)
end

Given /^an implementer "([^"]*)" for project "([^"]*)"  and an existing response$/ do |org, project|
  @project ||= Project.find_by_name(project)
  organization = Organization.find_by_name(org)
  @implementer = Factory.create( :implementer, 
                                 :project => @project,  
                                 :organization_id_from => organization.id )
end

Given /^an activity with name "([^\"]*)"$/ do |name|
  @activity = Factory.create(:activity, :name => name)
end

Given /^an activity with name "([^\"]*)" in project "([^\"]*)"$/ do |name, project|
  @activity = Factory.create(:activity, :name => name, :projects => [Project.find_by_name(project)])
end

Given /^an activity with name "([^\"]*)" in project "([^\"]*)" and an existing response$/ do |name, project|
  @activity = Factory.create(:activity, :name => name, :data_response => @data_response, :projects => [Project.find_by_name(project)])
end

Given /^the following projects$/ do |table|
  table.hashes.each do |hash|
    org  = Organization.find_by_name(hash.delete("organization"))
    Factory.create(:project,  { :organization_id => org.id
                              }.merge(hash) )
  end
end

Given /^a reporter "([^"]*)" with email "([^"]*)" and password "([^"]*)"$/ do | name, email, password|
  @user = Factory.create(:reporter, :username => name, :email => email, :password => password, :password_confirmation => password)
end

Given /^an activity manager "([^"]*)" with email "([^"]*)" and password "([^"]*)"$/ do | name, email, password|
  @user = Factory.create(:activity_manager, :username => name, :email => email, :password => password, :password_confirmation => password)
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

Given /^the root codes$/ do |table|
  table.hashes.each do |hash|
    f = Factory.create(:root_code, hash.merge(:type => 'Nha'))
  end
end

Given /^the following activity managers$/ do |table|
  table.hashes.each do |hash|
    org  = Organization.find_by_name(hash.delete("organization"))
    username  = hash.delete("name")
    Factory.create(:activity_manager, { :username => username,
                                        :organization_id => org.id
                                      }.merge(hash) )
  end
end



Given /^I am signed in as "([^"]*)"$/ do |name|
  steps %Q{
    When I go to the login page
    When I fill in "Username or Email" with "#{name}"
    And  I fill in "Password" with "password"
    And  I press "Sign in"
  }
end

Given /^I am signed in as a reporter$/ do
  steps %Q{
    Given a reporter "Frank" in organization "Test Org"
    Given I am signed in as "Frank"
  }
end

Given /^I am signed in as an activity manager$/ do
  steps %Q{
    Given an activity manager "Frank" in organization "Test Org"
    Given I am signed in as "Frank"
  }
end


Given /^an organization with name "([^"]*)"$/ do |name|
  @organization = Factory.create(:organization, :name => name)
end

Given /^a data request with title "([^\"]*)" from "([^\"]*)"$/ do |title, requestor|
  org  = Organization.find_by_name(requestor)
  @data_request = Factory.create(:data_request, :title => title, :requesting_organization => org)
end

Given /^the following organizations$/ do |table|
  table.hashes.each do |hash|
    Factory.create(:organization, hash)
  end
end

Given /^a reporter "([^"]*)" in organization "([^"]*)"$/ do |name, org_name|
  @organization = Factory.create(:organization, :name => org_name)
  @user = Factory.create(:reporter, :username => name, :email => 'frank@f.com', 
                          :password => 'password', :password_confirmation => 'password',
                          :organization => @organization)
end

Given /^an activity manager "([^"]*)" in organization "([^"]*)"$/ do |name, org_name|
  @organization = Factory.create(:organization, :name => org_name)
  @user = Factory.create(:activity_manager, :username => name, :email => 'frank@f.com', 
                          :password => 'password', :password_confirmation => 'password',
                          :organization => @organization)
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

Then /^I should see the visitors header$/ do
  steps %Q{
    Then I should see "Have an account?" within "div#header_app_app"
    And I should see "Sign in" within "div#header_app_app"
  }
end

Then /^I should see the reporters admin nav$/ do
  steps %Q{
    Then I should see "frank@f.com" within "div#header_app"
    Then I should see "My Profile" within "div#header_app"
    Then I should see "Sign out" within "div#header_app"
  }
end

Then /^I should see the common footer$/ do
  steps %Q{
    Then I should see "About" within "div#footer"
    Then I should see "Help" within "div#footer"
    Then I should see "Contact Us" within "div#footer"
    Then I should see "News" within "div#footer"
  }
end

Then /^I should see the main nav tabs$/ do
  steps %Q{
    Then I should see "Dashboard" within "div#main-nav"
    Then I should see "My Data" within "div#main-nav"
    Then I should see "Reports" within "div#main-nav"
    Then I should see "Help" within "div#main-nav"
  }
end

Then /^I should see the data response tabs$/ do
  steps %Q{
    Then I should see "Projects" within "li"
  }
end

Then /^I should not see the data response tabs$/ do
  steps %Q{
    Then I should not see "Projects" within "li"
  }
end

# use this when you need to match the EXACT value of a field (vs the "should contain" matcher) 
Then /^the "([^"]*)" field(?: within "([^"]*)")? should equal "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should == value
    else
      assert_equal(value, field_value)
    end
  end
end

# a bit brittle
When /^I fill in the percentage for "Human Resources For Health" with "([^"]*)"$/ do |amount|
   steps %Q{ When I fill in "activity_updates_1_percentage" with "#{amount}"}
end

Then /^the percentage for "Human Resources For Health" field should equal "([^"]*)"$/ do |amount|
  steps %Q{ Then the "activity_updates_1_percentage" field should equal "#{amount}"}
end


# band aid fix
Given /^a data response to "([^"]*)" by "([^"]*)"$/ do |request, org|  
  @data_response = DataResponse.new :data_request => DataRequest.find_by_title(request),
                                    :responding_organization => Organization.find_by_name(org)
  @data_response.save!
end

# refactor meeeee
Given /^a refactor_me_please current_data_response for user "([^"]*)"$/ do |name|
  @user = User.find_by_username name
  @data_response = DataResponse.last
  @user.current_data_response = @data_response
  @user.save!
end

Then /^wait a few moments$/ do
  sleep 20
end

When /^I wait until "([^"]*)" is visible$/ do |selector|
  page.has_css?("#{selector}", :visible => true)
end
