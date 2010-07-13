config.gem "ruby-debug"
#config.gem "rails-footnotes"
config.gem 'glennr-heroku_san', :lib => false

config.gem 'deep_merge'

config.cache_classes                                 = false
config.whiny_nils                                    = true
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.action_mailer.raise_delivery_errors           = false
