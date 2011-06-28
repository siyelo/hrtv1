# app/models/notifier.rb
class Notifier < ActionMailer::Base
  default_url_options[:host] = "resourcetracking.heroku.com"

  def password_reset_instructions(user)
    subject       "[Health Resource Tracker] Password Reset Instructions"
    from          "HRT Notifier <hrt-do-not-reply@hrtapp.com>"
    recipients    user.email
    sent_on       Time.now
    body          :password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def comment_notification(comment, users)
    subject       "[Health Resource Tracker] A Comment Has Been Made"
    from          "HRT Notifier <hrt-do-not-reply@hrtapp.com>"
    recipients    users.map{ |u| u.email }
    sent_on       Time.now
    body          :comment => comment
  end
end
