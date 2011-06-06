# Be sure to restart your server when you modify this file

RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require 'thread' #fixes uninitialized constant ActiveSupport::Dependencies::Mutex (NameError) on 2.3.8
require File.join(File.dirname(__FILE__), 'boot')

puts "WARN: $HRT_COUNTRY not set, defaulting to Rwanda" unless ENV['HRT_COUNTRY']
puts "Loading #{ENV['HRT_COUNTRY'] || "Rwanda"} environment."

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  # tell rails to load files from all subfolders in app/models/
  #config.load_paths += Dir["#{RAILS_ROOT}/app/models/*"].find_all { |f| File.stat(f).directory? }
  config.load_paths += %W(
                          #{RAILS_ROOT}/app/charts
                          #{RAILS_ROOT}/app/reports
                          #{RAILS_ROOT}/lib/named_scopes
                        )
  config.load_paths += Dir["#{RAILS_ROOT}/app/models/**/**"]

  # disable spoofing check
  # http://pivotallabs.com/users/jay/blog/articles/1216-standup-4-7-2010-disabling-rails-ip-spoofing-safeguard
  # PT: https://www.pivotaltracker.com/story/show/6509545
  config.action_controller.ip_spoofing_check = false
end

require 'array_extensions'
require 'version'
