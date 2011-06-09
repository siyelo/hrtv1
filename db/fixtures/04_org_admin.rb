require 'factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}

begin
  puts "creating org"
  org = Factory(:organization, :name => "internal_manager_org")
  puts "creating reporter user"
  @reporter = Factory(:manager, :email => 'manager@hrtapp.com', :organization => org,
    :password => 'si@yelo', :password_confirmation  => 'si@yelo')
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an Org 'internal_manager_org' or user with email 'manager@hrtapp.com'? "
else
  puts "=> reporter #{@reporter.name} created (org: #{@reporter.organization.name})"
end

begin
  @reporter ||= User.find_by_email 'manager@hrtapp.com'
  puts "creating response"
  @response = Factory(:data_response, :organization => @reporter.organization)
  puts "creating project"
  @project = Factory(:project, :data_response => @response, :budget => 100, :spend => 80)
  puts "creating activity & coding"
  Factory(:activity_fully_coded, :data_response => @response, :project => @project)
  puts "creating other costs & coding"
  Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
  puts "=> added sample data for reporter #{@reporter.name}"
rescue Exception => e
  puts e.message
end