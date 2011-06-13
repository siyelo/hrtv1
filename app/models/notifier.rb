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
  
  def send_user_invitation(user, inviter)
    subject       "[Health Resource Tracker] You have been invited to HRT"
    from          "HRT Notifier <hrt-do-not-reply@hrtapp.com>"
    recipients    user.email
    sent_on       Time.now
    body          :full_name => user.full_name,
                  :org => user.organization,
                  :invite_token => user.invite_token,
                  :follow_me => "To register follow this <a href=\"#{edit_registration_url}?invite_token=#{user.invite_token}\">link</a>",
                  :sys_admin_org => inviter.organization ? "(#{inviter.organization.try(:name)})" : '',
                  :inviter_name => inviter.full_name ||= inviter.email
  end
  
  def email_organisation_users(comment, data_response)
    subject       "[Health Resource Tracker] A Comment Has Been Made"
    from          "HRT Notifier <hrt-do-not-reply@hrtapp.com>"
    recipients    data_response.organization.users.map{ |u| u.email }
    sent_on       Time.now
    body          :comment_address => response_activity_url(data_response, comment.commentable), 
                  :comment => comment.comment, 
                  :comment_activity_name => comment.commentable.name,
                  :commenter => comment.user.try(:name)
  end
end
