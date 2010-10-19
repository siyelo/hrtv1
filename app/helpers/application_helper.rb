# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Usage: simply invoke title() at the top of each view
  # E.g.
  # - title "Home"
  def title(page_title)
    content_for(:title) { page_title }
  end

  # GR: I'd like to move this to its respective controller helper
  # - but it seems the AS plugin code has been modified to use this method?
  #
  # Converts a (string) number to a percentage, preserving the decimals (if they exist)
  #  99 => 99
  #  50.1 => 50.1
  def number_to_percentage(n)
    n = n.to_f
    return "" if n <= 0.0
    sprintf("%2.f", n)
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
