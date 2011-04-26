project_type = :rails
project_path = Compass::AppIntegration::Rails.root
# Set this to the root of your project when deployed:
http_path = "/"
css_dir = "public/stylesheets/compiled"
sass_dir = "app/stylesheets"
environment = Compass::AppIntegration::Rails.env
# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true
preferred_syntax = :sass

#fix for heroku
require "fileutils"
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets", "compiled"))
#ActionController::Dispatcher.middleware.use(Rack::Static, :root => "tmp/", :urls => ["/stylesheets/compiled"])
#
