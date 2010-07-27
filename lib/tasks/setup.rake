desc "Install gems and do db:setup"
task :setup => ["gems:install", "db:drop:all", "db:create:all",  "db:migrate", "db:populate", "db:seed"]
