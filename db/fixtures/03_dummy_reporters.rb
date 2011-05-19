require 'factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}

begin
  puts "creating reporter"
  org = Factory(:organization, :name => "internal_reporter_org")
  @reporter = Factory(:reporter, :username => 'reporter', :email => 'reporter@eg.com', :organization => org)
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_reporter_org' or user named 'reporter'? "
else
  puts "=> reporter #{@reporter.name} created (org: #{@reporter.organization.name})"

  @response = Factory(:data_response, :organization => @reporter.organization)
  @project = Factory(:project, :data_response => @response, :budget => 100, :spend => 80)
  Factory(:activity_fully_coded, :data_response => @response, :project => @project)
  Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
  puts " added sample data for reporter #{@reporter.name}"
end

begin
  puts "creating activity_manager"
  org = Factory(:organization, :name => "internal_activity_manager_org")
  am = Factory(:activity_manager, :username => 'activity_manager',  :email => 'am@eg.com', :organization => org)
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_activity_manager_org' or user named 'activity_manager'? "
else
  print "=> activity_manager #{am.name} created (org: #{am.organization.name})"
end