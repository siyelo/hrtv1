namespace :db do
  desc "Loads unicef data."
  task :load_unicef => :environment do
    puts "Loading AM users in environment #{RAILS_ENV}"
    load File.join(RAILS_ROOT, 'db', 'fixes', '20110429_load_unicef_hiv_activities.rb')
  end
end
