namespace :reports do
  task :activities_by_district => :environment do
    puts "Creating report for #{RAILS_ENV}"
    load File.join(RAILS_ROOT, 'db', 'reports', 'activities_by_district.rb')
  end
end
