#create dummy users
User.create!(:username => 'admin',
              :email => 'admin@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :roles => ['admin'])

#create dummy users
User.create!(:username => 'reporter',
              :email => 'reporter@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :roles => ['reporter'])
