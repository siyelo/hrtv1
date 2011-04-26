# app/models/notifier.rb
class Notifier < ActionMailer::Base
  default :from => "HRT Notifier <hrt-do-not-reply@hrtapp.com>", 
          :host => "resourcetracking.heroku.com"

  def password_reset_instructions(user)
    @password_reset_url = edit_password_reset_url(user.perishable_token)
    mail :to => user.email, 
         :subject => "[Health Resource Tracker] Password Reset Instructions"
  end
  
  def email_organisation_users(comment, data_response)
    @comment_address       = response_activity_url(data_response, comment.commentable)
    @comment               = comment.comment
    @comment_activity_name = comment.commentable.name
    @commenter             = comment.user.try(:name)

    mail :to => data_response.organization.users.map{ |u| u.email }, 
         :subject => "[Health Resource Tracker] A Comment Has Been Made"
  end
end
