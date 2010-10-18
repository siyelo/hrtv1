#create dummy users
user = User.find_or_create_by_username('admin',
                :email => 'admin@ubuzima.org',
                :password => ENV['ADMIN_PASS'] || 'password',
                :password_confirmation => ENV['ADMIN_PASS'] || 'password',
                :organization => Organization.find_or_create_by_name("internal_for_dev"),
                :roles => ['admin'])

print "  WARN: Admin not created" unless user

