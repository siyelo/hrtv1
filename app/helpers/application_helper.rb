# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Adds title on page
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Adds javascripts to head
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end
  
  # Adds stylesheets to head
  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end
  
  # Adds keywords to page
  def keywords(page_keywords)
    content_for(:keywords) { page_keywords }
  end
  
  # Adds description to page
  def description(page_description)
    content_for(:description) { page_description }
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
