source 'http://rubygems.org'
#source "http://gems.github.com"

gem 'rails'
gem 'authlogic'
gem 'aws-s3', :require => 'aws/s3'
gem 'compass'
gem 'fastercsv'
gem 'formtastic', '1.2.3'
gem 'haml'
gem 'hoptoad_notifier'

# grr - money 3.5 depends on i18n 0.4+
# but 0.3.3 seems to solve the {{errors}} issue
#gem 'i18n', "= 0.3.3" #see https://github.com/svenfuchs/i18n/issues/71

gem 'inherited_resources'
gem 'money'
gem "paperclip"
gem 'settingslogic'
gem 'validates_date_time'
gem 'version'
#gem 'will_paginate' # use rails 3 gem
gem 'json_pure'
gem 'hassle', :git => 'git://github.com/koppen/hassle.git'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:

group :development do
  gem 'annotate'
  gem 'awesome_print', :require => "ap"
  #gem 'github' # misbehaving uninitialized constant Text::Format
  gem 'google_currency' # for currency cacher
  gem 'heroku'
  gem 'hirb'
  gem 'interactive_editor'
  #gem 'looksee' # prevents inherited_resource to assign instance variables !!
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
  gem 'rspec'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'launchy'               # So you can do 'Then show me the page'
  gem 'pickle'
  gem 'ruby-pg'
  gem 'shoulda'
  gem 'spork'
  gem 'email_spec'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-bundler'
  gem 'guard-spork'
  # gem 'libnotify'
  gem 'growl'
  gem 'rb-fsevent' # inject GoFast Juice (TM) into Guard on OSX
end
