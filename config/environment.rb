# Be sure to restart your server when you modify this file

RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "fastercsv"
  config.gem "haml",    :version => "= 3.0.12"
  config.gem "compass", :version => "= 0.10.2"

  config.time_zone = 'UTC'

end
