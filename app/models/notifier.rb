# app/models/notifier.rb
class Notifier < ActionMailer::Base
  default_url_options[:host] = "resourcetracking.heroku.com"

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          "HRT Notifier "
    recipients    user.email
    sent_on       Time.now
    body          :password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
