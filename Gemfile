source 'http://rubygems.org'
#source "http://gems.github.com"

gem 'acts_as_tree'
gem 'ar_strip_commas'
gem 'authlogic'
gem 'aws-s3', :require => 'aws/s3'
gem 'compass', '=0.10.2'
gem 'fastercsv'
gem 'formtastic', "= 1.2.3"
gem 'haml', '=3.1.2'
gem 'hoptoad_notifier'
gem 'inherited_resources', "=1.0.6"
gem 'inherited_resources', '= 1.0.6'
gem 'json_pure'
gem 'money', "~> 3.5"
gem 'paperclip', "= 2.3.11"
gem 'rails', '2.3.12'
gem 'rdoc'
gem 'sass', '=3.1.4'
gem 'settingslogic'
gem 'validates_timeliness', '~> 2.3'
gem 'version'
gem 'will_paginate', "~> 2.3.11"

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:

group :development do
  gem 'annotate'
  gem 'awesome_print', :require => "ap"
  gem 'factory_girl', '1.2.4' # moving it here so not loaded by spork prefork. NB. some specs fail with 1.3.3
  gem 'google_currency', "=1.2.0" # for currency cacher
  gem 'heroku', '>= 2.1.2'
  gem 'hirb'
  gem 'interactive_editor'
  gem 'mongrel'
  gem 'open_gem'
  gem 'rails-footnotes'
  gem 'ruby-debug'
  gem 'sketches'
  gem 'slurper', :require => false
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'taps'
  gem 'wirble'
end

group :test, :development do
  # gem 'mysql'
  gem 'rcov'
  gem 'rspec', '1.3.1', :require => 'spec'
  gem 'rspec-rails', '1.3.3'  # RSpec 1 (1.3.x) is for Rails 2.3.x
end

group :test do
  gem 'capybara', '0.3.9'     # latest capy fails with "undefined method `fillable_field' for HTML:Module"
  gem 'selenium-webdriver', '~>0.2.2'
  gem 'cucumber'
  gem 'cucumber-rails', '0.3.2'
  gem 'database_cleaner'
  gem 'email_spec', :git => 'git://github.com/bmabey/email-spec.git', :branch => '0.6-rails2-compat'
  gem 'gherkin', '2.3.7'
  gem 'growl'
  gem 'guard'
  gem 'guard-bundler'
  #gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'launchy'               # So you can do 'Then show me the page'
  gem 'pickle', '~> 0.4.4'
  gem 'rb-fsevent' # inject GoFast Juice (TM) into Guard on OSX
  gem 'ruby-pg'
  gem 'shoulda'
  gem 'spork', '~> 0.8'
end
