User.stub_current_user_and_data_response
#create dummy users
User.create! (:username => 'reporter',
              :email => 'reporter@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :organization => Organization.create!(:name => "internal_for_dev2"),
              :roles => ['reporter'])

User.create! (:username => 'reporter2',
              :email => 'reporter2@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :organization => Organization.create!(:name => "internal_for_dev3"),
              :roles => ['reporter'])
User.unstub_current_user_and_data_response
