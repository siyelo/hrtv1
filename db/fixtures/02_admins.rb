require 'factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}

begin
  puts "creating admin"
  org = Factory(:organization, :name => 'internal_admin_org')
  admin = Factory(:admin, :email => 'admin@hrt.com', :organization => org)
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'admin_org' or user named 'admin'? "
else
  puts "=> admin user: #{admin.name} created (org: #{admin.organization.name})"
end
