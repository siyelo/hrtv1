# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Sets titles on pages
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Creates unique id for HTML document body used for unobtrusive javascript selectors
  def get_controller_id(controller)
    parts = controller.controller_path.split('/')
    parts << controller.action_name
    parts.join('_')
  end

  # Generates proper dashboard url link depending on the type of user
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
