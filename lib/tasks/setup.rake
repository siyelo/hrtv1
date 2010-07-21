namespace :setup do
  desc "Install gems and do db:setup"
  task :basic => ["gems:install", "db:setup", "db:populate"]

  desc "Copy all example yamls into place automatically"
  task :yamls => :environment do
    system "cp #{RAILS_ROOT}/config/database.yml.sample #{RAILS_ROOT}/config/database.yml"
    system "cp #{RAILS_ROOT}/config/settings.secret.example.yml #{RAILS_ROOT}/config/settings.secret.yml"
  end

  desc 'Do all needed to get the app setup (for dev or test only)'
  task :all => [:yamls, :basic]

end

task :setup => 'setup:basic'
task :default => :setup