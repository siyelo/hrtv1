org = Organization.find_or_create_by_name("internal_for_dev2")
saved = User.find_or_create_by_username('reporter',
              :email => 'reporter@siyelo.com',
              :password => 'password',
              :password_confirmation => 'password',
              :organization_id => org.id,
              :roles => ['reporter'])

print "  WARN: reporter not created" unless saved

org = Organization.find_or_create_by_name("internal_for_dev3")
saved = User.find_or_create_by_username('reporter2',
              :email => 'reporter2@siyelo.com',
              :password => 'password',
              :password_confirmation => 'password',
              :organization_id => org.id,
              :roles => ['reporter'])

print "  WARN: reporter2 not created" unless saved

org =  Organization.find_or_create_by_name("internal_for_dev3")
user = User.find_or_create_by_username('activity_manager',
              :email => 'activity_manager@siyelo.com',
              :password => 'password',
              :password_confirmation => 'password',
              :organization_id => org.id,
              :roles => ['activity_manager'])
dr = org.data_responses.first
user.current_data_response = dr
user.save!
print "  WARN: activity_manager not created" unless user

org = Organization.find_or_create_by_name("internal_for_dev4")
saved = User.find_or_create_by_username('developer',
              :email => 'support@siyelo.com',
              :password => 'password',
              :password_confirmation => 'password',
              :organization_id => org.id,
              :roles => ['reporter'])

print "  WARN: developer account not created" unless saved
