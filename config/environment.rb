# Be sure to restart your server when you modify this file

RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

require 'yaml'
require 'erb'
config_file_path = File.join(RAILS_ROOT, 'config', 'settings.secret.yml')
config_file_path = File.join(RAILS_ROOT, 'config', 'settings.yml') if ['production', 'staging'].include?(RAILS_ENV)
if File.exist?(config_file_path)
  config = YAML.load(ERB.new(File.read(config_file_path)).result)
  if config && config.has_key?(RAILS_ENV)
    APP_CONFIG = config.has_key?(RAILS_ENV) ? config[RAILS_ENV] : {}
  else
    APP_CONFIG = {}
    puts "WARN: config file #{config_file_path} is not valid"
  end
else
  APP_CONFIG = {}
  puts "WARN: configuration file #{config_file_path} not found."
end

Rails::Initializer.run do |config|

  config.gem "fastercsv"
  config.gem "haml",    :version => "= 3.0.13"
  config.gem "compass", :version => "= 0.10.2"
  config.gem 'hoptoad_notifier'
  config.gem "authlogic"
  config.gem "cancan"

  config.time_zone = 'UTC'

end

