require 'compass'
rails_root = (defined?(Rails) ? Rails.root : RAILS_ROOT).to_s
Compass.add_project_configuration(File.join(rails_root, "config", "compass.rb"))
Compass.configure_sass_plugin!
Compass.handle_configuration_change!

#fix for heroku
require "fileutils"
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets", "compiled"))
ActionController::Dispatcher.middleware.use(Rack::Static, :root => "tmp/", :urls => ["/stylesheets/compiled"])