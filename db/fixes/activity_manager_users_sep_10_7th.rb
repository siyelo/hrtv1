# Creation of users

puts "\nLoading users"

def friendly_token
  ActiveSupport::SecureRandom.base64(8).tr('+/=', '-_ ').strip.delete("\n")
end

i = 1
auto_created_passwords = []
FasterCSV.foreach("db/fixes/activity_manager_users_sep_10_7th.csv", :headers => true ) do |row|
  i = i + 1
  org_name      = row[3].try(:strip)
  user_email    = row[2].try(:strip)
  username      = user_email.split('@').first #row[1].try(:strip)
  #full_name     = row[0].try(:strip)
  user_password = row[4].try(:strip)

  unless user_password
    user_password = friendly_token
    auto_created_passwords << "#{org_name}, #{user_email}, #{username}, #{user_password}"
  end
  org           = Organization.find_by_name(org_name)

  print "Creating #{user_email}, #{username}, #{user_password}, #{org_name}\n"
  puts "  WARN: Cannot find organization \"#{org_name}\" in the database (row: \# #{i})" unless org

  existing_user = User.find_by_email(user_email)
  puts "  WARN: User \"#{user_email}\" already exists (row: \# #{i})" if existing_user
  existing_user.delete if existing_user# otherwise will ahve users referencing non existent data responses potentially

  #create dummy users

  if org
    user = User.create(:username => username,
               :email => user_email,
               :password => user_password,
               :password_confirmation => user_password,
               :organization => org,
               :roles => ['activity_manager'])
   dr                          = org.data_responses.first if org.data_responses
   user.current_data_response = dr
   user.save!
  end

  print "  WARN: reporter \"#{user_email}\" not created!!!" unless user && org

end

unless auto_created_passwords.empty?
  puts "INFO: auto-created passwords for:"
  auto_created_passwords.each { |p| puts p }
end

puts "...Loading users DONE\n"