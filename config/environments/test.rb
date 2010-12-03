config.gem 'rspec',            :lib => false, :version => '>= 1.3.0' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec'))
config.gem 'rspec-rails',      :lib => false, :version => '>= 1.3.2' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
config.gem 'shoulda'
config.gem "factory_girl",     :lib => false, :version => '=1.2.4'

config.cache_classes                                 = true
config.whiny_nils                                    = true
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true
config.action_controller.allow_forgery_protection    = false
config.action_mailer.delivery_method                 = :test

if ENV.include?('I_LOVE_METRICS')
  config.gem "metric_fu",         :version => '1.5.1', :lib => 'metric_fu'
end
