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
  
  def email_organisation_users(comment, commenter,emails)
    subject       "[Health Resource Tracker] A Comment Has Been Made"
    from          "HRT Notifier <hrt-do-not-reply@hrtapp.com>"
    recipients    emails
    sent_on       Time.now
    body          :comment_address => response_activity_url(comment.commentable.data_response_id, comment.commentable), 
                  :comment => comment.comment, 
                  :comment_activity_name => comment.commentable.name,
                  :commenter => commenter
  end
end
