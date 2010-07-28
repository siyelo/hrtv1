desc "Install gems and do db:setup (with seeds/fixtures)"
task :setup => ["gems:install", "db:setup", "db:populate"]

desc "Install gems create blank database"
task :setup_quick => ["gems:install", 'db:create', 'db:schema:load']
