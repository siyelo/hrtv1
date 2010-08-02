User.stub_current_user_and_data_response
#create dummy users
User.create! (:username => 'admin',
              :email => 'admin@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :organization => Organization.create!(:name => "internal_for_dev"),
              :roles => ['admin'])

User.unstub_current_user_and_data_response
