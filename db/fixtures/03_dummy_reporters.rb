require 'factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}
## REPORTER
begin
  puts "creating org"
  @org = Factory(:organization, :name => "internal_reporter_org")
  puts "creating reporter user"
  @reporter = Factory(:reporter, :email => 'reporter@hrtapp.com', :organization => @org,
    :password => ENV['HRT_REPORTER_PASSWORD'] || 'si@yelo',
    :password_confirmation => ENV['HRT_REPORTER_PASSWORD'] || 'si@yelo')
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_reporter_org' or user named 'reporter'? "
else
  puts "=> reporter #{@reporter.name} created (org: #{@reporter.organization.name})"
end

begin
  @reporter ||= User.find_by_email 'reporter@hrtapp.com'
  puts "creating project"
  @project = Factory(:project, :organization => @org)
  puts "creating activity & coding"
  Factory(:activity_fully_coded, :organization => @org, :project => @project)
  puts "creating other costs & coding"
  Factory(:other_cost_fully_coded, :organization => @org, :project => @project)
  puts "=> added sample data for reporter #{@reporter.name}"
rescue Exception => e
  puts e.message
end

##ACTIVITY MANAGER
begin
  puts "creating activity_manager"
  @org = Factory(:organization, :name => "internal_activity_manager_org")
  am = Factory(:activity_manager, :email => 'activity_manager@hrtapp.com',
    :organization => @org,
    :password => ENV['HRT_ACTIVITY_MGR_PASSWORD'] || 'si@yelo',
    :password_confirmation => ENV['HRT_ACTIVITY_MGR_PASSWORD'] || 'si@yelo')
  # assign some nice existing orgs
  orgs = [ 'JSI', 'Tulane University', 'ICAP', 'Access Project', 'TRAC+ - HIV', 'Voxiva']
  query = orgs.map{ |o| "name like ?"}.join(' OR ')
  am.organizations = Organization.find(:all, :conditions => [query, *orgs.map{|o| "%#{o}%"}])
  am.save
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_activity_manager_org' or user named 'activity_manager'? "
else
  print "=> activity_manager #{am.name} created (org: #{am.organization.name})"
end

begin
  puts "creating district manager"
  @org = Factory(:nonreporting_organization, :name => "internal_district_manager_org")
  dm = Factory(:district_manager, :email => 'district_manager@hrtapp.com',
    :organization => @org,
    :password => ENV['HRT_ACTIVITY_MGR_PASSWORD'] || 'si@yelo',
    :password_confirmation => ENV['HRT_ACTIVITY_MGR_PASSWORD'] || 'si@yelo')
  # assign some nice existing orgs
  dm.location = Location.first
  dm.save
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_district_manager_org' or user named 'district_manager@hrtapp.com'? "
else
  print "=> district manager #{dm.name} created (org: #{dm.organization.name})"
end

