# Creation of users

puts "\nLoading users"

### Expected format
# <Org Name>, <User Email>

def friendly_token
  ActiveSupport::SecureRandom.base64(8).tr('+/=', '-_ ').strip.delete("\n")
end

i = 1
auto_created_passwords = []
FasterCSV.foreach("db/fixtures/files/users.csv", :headers => true ) do |row|
  i = i + 1
  org_name      = row[0].try(:strip)
  user_email    = row[1].try(:strip)
  user_password = row[2].try(:strip)

  unless user_password
    user_password = friendly_token
    auto_created_passwords << "#{org_name}, #{user_email}, #{user_password}"
  end
  org           = Organization.find_by_name(org_name)
  puts "  WARN: Cannot find organization \"#{org_name}\" in the database (row: \# #{i})" unless org

  existing_user = User.find_by_email(user_email)
  puts "  WARN: User \"#{user_email}\" already exists (row: \# #{i})" if existing_user
  existing_user.delete if existing_user# otherwise will ahve users referencing non existent data responses potentially

  User.stub_current_user_and_data_response
  #create dummy users

  saved = User.create(:username => user_email,
               :email => user_email,
               :password => user_password,
               :password_confirmation => user_password,
               :organization => org,
               :roles => ['reporter'])
  print "  WARN: reporter \"#{user_email}\" not created" unless saved
  print "."

  User.unstub_current_user_and_data_response

end

unless auto_created_passwords.empty?
  puts "INFO: auto-created passwords for:"
  auto_created_passwords.each { |p| puts p }
end

puts "...Loading users DONE\n"
