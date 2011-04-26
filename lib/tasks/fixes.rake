namespace :db do
  desc "Loads initial database models for the current environment."
  task :fix_am_users => :environment do
    puts "Loading AM users in environment #{Rails.env}"
    load File.join(Rails.root, 'db', 'fixes', 'activity_manager_users_sep_10.rb')
  end

  task :fix_am_users_7th => :environment do
    puts "Loading AM users in environment #{Rails.env}"
    load File.join(Rails.root, 'db', 'fixes', 'activity_manager_users_sep_10_7th.rb')
  end
end
