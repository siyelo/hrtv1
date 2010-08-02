User.stub_current_user_and_data_response
#create dummy users
saved = User.create(:username => 'admin',
                    :email => 'admin@ubuzima.org',
                    :password => ENV['ADMIN_PASS'] || 'password',
                    :password_confirmation => ENV['ADMIN_PASS'] || 'password',
                    :organization => Organization.create!(:name => "internal_for_dev"),
                    :roles => ['admin'])

print "  WARN: Admin not created" unless saved

User.unstub_current_user_and_data_response
