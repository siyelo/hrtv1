#create dummy users
User.create! (:username => 'admin',
              :email => 'admin@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :organization => Organization.create!(:name => "internal_for_dev"),
              :roles => ['admin'])

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
