class CommentObserver < ActiveRecord::Observer

  def after_create(comment)
    users = comment.parent_id? ?
      comment.ancestors.map(&:user) : comment.user.organization.users
    users = users.reject{|u| u == comment.user} # reject commenter
    Notifier.deliver_comment_notification(comment, users)
  end
end
