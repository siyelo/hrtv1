desc "Install gems and do db:setup"
task :setup => ["gems:install", "db:setup", "db:populate"]
