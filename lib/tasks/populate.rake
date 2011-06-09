namespace :db do
  desc "Loads initial database models for the current environment."
  task :populate => :environment do
    puts "Populating environment #{RAILS_ENV}"
    Dir[File.join(RAILS_ROOT, 'db', 'fixtures', '*.rb')].sort.each { |fixture| puts "Loading #{fixture}\n"; load fixture }
    Dir[File.join(RAILS_ROOT, 'db', 'fixtures', RAILS_ENV, '*.rb')].sort.each { |fixture| "Loading #{fixture}\n"; load fixture }
  end

  # this fixture file no long exists
  #task :populate_users => :environment do
  #  puts "Populating users in environment #{RAILS_ENV}"
  #  load File.join(RAILS_ROOT, 'db', 'fixtures', '04_users.rb')
  #end

  desc "Resets user passwords for current environment."
  task :password_reset => :environment do
    puts "Reseting user passwords for environment #{RAILS_ENV}"
    password = 'si@yelo'
    User.all.each{|u| u.password = password; u.password_confirmation = password; u.save}
    puts "------------------------------------------------------------------"
    puts "Passwords are reset to: '#{password}'"
    puts "------------------------------------------------------------------"
    puts "You can use following users for login:"
    puts "------------------------------------------------------------------"
    puts Organization.all.select{|o| o.users.count > 0}.map{|o| o.users.first.email}
    puts "------------------------------------------------------------------"
  end
end
