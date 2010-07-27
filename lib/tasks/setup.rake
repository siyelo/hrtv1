desc "Install gems and do db:setup"
task :setup => ["gems:install", "db:drop", "db:create",  "db:migrate", "db:populate", "db:seed"]
