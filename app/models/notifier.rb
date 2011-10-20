# app/models/notifier.rb
class Notifier < ActionMailer::Base
  #default_url_options[:host] = "resourcetracking.heroku.com"
  FROM = "HRT Notifier <hrt-do-not-reply@hrtapp.com>"

  def password_reset_instructions(user)
    subject       "[Health Resource Tracker] Password Reset Instructions"
    from          FROM
    recipients    user.email
    sent_on       Time.now
    body          :password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def comment_notification(comment, users)
    subject       "[Health Resource Tracker] A Comment Has Been Made"
    from          FROM
    recipients    users.map{ |u| u.email }
    sent_on       Time.now
    body          :comment => comment
  end

  def send_user_invitation(user, inviter)
    subject       "[Health Resource Tracker] You have been invited to HRT"
    from          FROM
    recipients    user.email
    sent_on       Time.now
    body          :full_name => user.full_name,
                  :org => user.organization,
                  :invite_token => user.invite_token,
                  :follow_me => "#{edit_registration_url}?invite_token=#{user.invite_token}",
                  :sys_admin_org => inviter.organization ? "(#{inviter.organization.try(:name)})" : '',
                  :inviter_name => inviter.full_name ||= inviter.email
  end

  def response_rejected_notification(response)
    subject       "Your #{response.title} response is Rejected"
    from          FROM
    recipients    response.organization.users.map{ |u| u.email }
    sent_on       Time.now
  end

  def response_accepted_notification(response)
    subject       "Your #{response.title} response is Accepted"
    from          FROM
    recipients    response.organization.users.map{ |u| u.email }
    sent_on       Time.now
  end

  def report_download_notification(user, report)
    report_name = Report.key_to_name(report.key)
    subject       "Download link for #{report_name} report"
    from          FROM
    recipients    user.email
    sent_on       Time.now
    body          :report => report, :report_name => report_name
 end
end
