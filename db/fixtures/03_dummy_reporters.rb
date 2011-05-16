require 'factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}
response = Factory.create(:data_response, :organization => reporter.organization)
Factory(:project, :data_response => response, :budget => 100, :spend => 80)
Factory(:activity_fully_coded, :data_response => response, :project => @project)
Factory(:other_cost_fully_coded, :data_response => response, :project => @project)
print " added sample data for reporter #{reporter.name}"

am = Factory(:activity_manager)
print "=> activity_manager #{am.name} created (org: #{am.organization.name})"
