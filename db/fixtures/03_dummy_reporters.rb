saved = User.find_or_create_by_username('reporter',
              :email => 'reporter@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :organization => Organization.find_or_create_by_name("internal_for_dev2"),
              :roles => ['reporter'])

print "  WARN: reporter not created" unless saved

saved = User.find_or_create_by_username('reporter2',
              :email => 'reporter2@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :organization => Organization.find_or_create_by_name("internal_for_dev3"),
              :roles => ['reporter'])

print "  WARN: reporter2 not created" unless saved

org =  Organization.find_or_create_by_name("internal_for_dev3")
user = User.find_or_create_by_username('activity_manager',
              :email => 'activity_manager@ubuzima.org',
              :password => 'password',
              :password_confirmation => 'password',
              :organization => org,
              :roles => ['activity_manager'])
dr = org.data_responses.first
user.current_data_response = dr
user.save!
print "  WARN: activity_manager not created" unless user
