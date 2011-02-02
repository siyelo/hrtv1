# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.
if defined?(ActiveRecord::Base)
  begin
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation, { :except => %w[codes model_helps currencies] }
    DatabaseCleaner.clean
  rescue LoadError => ignore_if_database_cleaner_not_present
  end
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end


