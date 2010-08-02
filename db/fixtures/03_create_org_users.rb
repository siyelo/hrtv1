# Creation of users

puts "\nLoading users"
puts "  Loading users.csv"

### Expected format
# <Org Name>, <User Email>

i = 1
FasterCSV.foreach("db/seed_files/users.csv", :headers => true ) do |row|
  i = i + 1
  org_name   = row[0].try(:strip)
  user_email = row[1].try(:strip)
  org        = Organization.find_by_name(org_name)
  puts "  WARN: Cannot find organization \"#{org_name}\" in the database (row: \# #{i})" unless org

  existing_user = User.find_by_email(user_email)
  puts "  WARN: User \"#{user_email}\" already exists (row: \# #{i})" if existing_user

  User.stub_current_user_and_data_response
  #create dummy users
  User.create!(:username => user_email,
               :email => user_email,
               :password => 'password',
               :password_confirmation => 'password',
               :organization => org,
               :roles => ['reporter'])

  User.unstub_current_user_and_data_response

end
puts "...Loading users DONE\n"