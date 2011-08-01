require 'factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}
## REPORTER
begin
  puts "creating org"
  org = Factory(:organization, :name => "internal_reporter_org")
  puts "creating response"
  response = org.latest_response
  puts "creating reporter user"
  reporter = Factory(:reporter, :email => 'reporter@hrtapp.com', :organization => org,
    :password => 'si@yelo', :password_confirmation => 'si@yelo')
  puts "creating project"
  project = Factory(:project, :data_response => response, :budget => 100, :spend => 80)
  activity   = Factory(:activity, :data_response => response, :project => project,
                       :name => 'activity1', :description => 'activity1',
                       :budget => 80, :spend => 60)
  other_cost = Factory(:other_cost, :data_response => response, :project => project,
                       :name => 'other_cost1', :description => 'other_cost1',
                       :budget => 20, :spend => 20)
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_reporter_org' or user named 'reporter'? "
else
  puts "=> reporter #{reporter.name} created (org: #{reporter.organization.name})"
end

##ACTIVITY MANAGER
begin
  puts "creating activity_manager"
  org = Factory(:organization, :name => "internal_activity_manager_org")
  am = Factory(:activity_manager, :email => 'activity_manager@hrtapp.com',
    :organization => org,
    :password => 'si@yelo', :password_confirmation => 'si@yelo')
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_activity_manager_org' or user named 'activity_manager'? "
else
  print "=> activity_manager #{am.name} created (org: #{am.organization.name})"
end


