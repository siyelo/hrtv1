require 'factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}
## REPORTER
begin
  puts "creating org"
  org = Factory(:organization, :name => "internal_reporter_org")
  puts "creating reporter user"
  @reporter = Factory(:reporter, :email => 'reporter@hrtapp.com', :organization => org)
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_reporter_org' or user named 'reporter'? "
else
  puts "=> reporter #{@reporter.name} created (org: #{@reporter.organization.name})"
end

@reporter ||= User.find_by_email 'reporter@hrtapp.com'
puts "creating response"
@response = Factory(:data_response, :organization => @reporter.organization)
puts "creating project"
@project = Factory(:project, :data_response => @response, :budget => 100, :spend => 80)
puts "creating activity & coding"
Factory(:activity_fully_coded, :data_response => @response, :project => @project)
puts "creating other costs & coding"
Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
puts "=> added sample data for reporter #{@reporter.name}"


##ACTIVITY MANAGER
begin
  puts "creating activity_manager"
  org = Factory(:organization, :name => "internal_activity_manager_org")
  am = Factory(:activity_manager, :email => 'activity_manager@hrtapp.com', :organization => org)
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_activity_manager_org' or user named 'activity_manager'? "
else
  print "=> activity_manager #{am.name} created (org: #{am.organization.name})"
end


