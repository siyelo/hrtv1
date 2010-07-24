module UsersHelper
  def user_dashboard_path current_user
    path = nil
    if current_user
      if current_user.role? :admin
        path = static_page_path(:admin_dashboard)
      elsif current_user.role? :reporter
        path = static_page_path(:reporter_dashboard)
      end
    end
    path
  end
  def user_dashboard_link link_text = "Back to Dashboard"
    link_to link_text, user_dashboard_path(current_user)
  end
end
