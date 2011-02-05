desc "This task is called by the Heroku cron add-on. Caches long running reports each day."
task :cron => :environment do
  Rake::Task["reports:all"].invoke 
end
