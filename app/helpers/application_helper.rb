# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Usage: simply invoke title() at the top of each view
  # E.g.
  # - title "Home"
  def title(page_title)
    content_for(:title) { page_title }
  end

  def get_controller_id(controller)
    parts = controller.controller_path.split('/')
    parts << controller.action_name
    parts.join('_')
  end

  def user_dashboard_path current_user
    if current_user
      if current_user.role? :admin
        admin_dashboard_path
      elsif current_user.role? :reporter
        reporter_dashboard_path
      end
    end
  end
end
