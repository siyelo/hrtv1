require File.expand_path('../boot', __FILE__)

require 'rails/all'

puts "WARN: $HRT_COUNTRY not set, defaulting to Rwanda" unless ENV['HRT_COUNTRY']
puts "Loading #{ENV['HRT_COUNTRY'] || "Rwanda"} environment."

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module ResourceTracking
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
                                 #{Rails.root}/lib
                                 #{Rails.root}/app/charts
                                 #{Rails.root}/app/reports
                                 #{Rails.root}/lib/named_scopes
                               )
    config.autoload_paths += Dir["#{Rails.root}/app/models/**/**"]

    config.action_dispatch.ip_spoofing_check = false

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]
    config.secret_token = '0cf70cf1c875a9942dab90096a415174255046e4dcc2a5337076662c49a731795b395e9044ec7456c3e4c25ba1bc7c8fb032de961f37505c2ba4fdd94f98e829'

    config.generators do |g|
      g.template_engine :haml
    end
  end
end

require 'array_extensions'
require 'version'
Sass::Plugin.options[:template_location] = { 'app/stylesheets' => 'tmp/stylesheets/compiled' }
