source 'http://rubygems.org'
#source "http://gems.github.com"

gem 'authlogic'
gem 'aws-s3', :require => 'aws/s3'
gem 'cancan'
gem 'compass', '=0.10.2'
gem 'fastercsv'
gem 'formtastic', "= 0.9.10"
gem 'google_currency'
gem 'haml'
gem 'hoptoad_notifier'
gem 'i18n', '=0.4.2'
gem 'inherited_resources', "=1.0.6"
gem 'money'
gem "paperclip", "~> 2.3"
gem 'rails', '2.3.8'
gem 'settingslogic'
gem 'validates_date_time', "= 1.0.0"
gem 'version'
gem 'will_paginate', "~> 2.3.11"
gem 'json_pure'
gem 'inherited_resources', '= 1.0.6'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:

group :development do
  gem 'annotate'
  gem 'awesome_print', :require => "ap"
  gem 'heroku'
  gem 'hirb'
  gem 'interactive_editor'
  gem 'looksee'
  gem 'mongrel'
  gem 'open_gem'
  gem 'rails-footnotes'
  gem 'ruby-debug'
  gem 'sketches'
  gem 'slurper'
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'taps'
  gem 'wirble'
end

group :test, :development do
  gem 'rspec', '1.3.1'
  gem 'rspec-rails', '1.3.3'  # RSpec 1 (1.3.x) is for Rails 2.3.x
end

group :test do
  gem 'capybara', '0.3.9'     # latest capy fails with "undefined method `fillable_field' for HTML:Module"
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'factory_girl', '1.2.4' # some specs fail with 1.3.3
  gem 'launchy'               # So you can do 'Then show me the page'
  gem 'pickle', '~> 0.4.4'
  gem 'ruby-pg'
  gem 'shoulda'
  gem 'spork'
end
