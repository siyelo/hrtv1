config.cache_classes                                 = false
config.whiny_nils                                    = true
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.action_mailer.raise_delivery_errors           = false

config.action_mailer.delivery_method = :file

class ActionMailer::Base
 def perform_delivery_file(mail)
   File.open("#{Rails.root}/tmp/mails/#{mail.to} - #{mail.subject}.eml", 'w') { |f| f.write(mail) }
 end
end