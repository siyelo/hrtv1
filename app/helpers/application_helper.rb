# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Does not check that this is a valid class
  def controller_model_class
    c = controller_name.to_s.pluralize.singularize.camelize.constantize
    if c.respond_to? :new
      c # looks like we've got a real class
    else
      nil # TODO throw error?
    end
  end

  # Usage: simply invoke title() at the top of each view
  # E.g.
  # - title "Home"
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Converts a (string) number to a percentage, preserving the decimals (if they exist)
  #  99 => 99
  #  50.1 => 50.1
  def number_to_percentage(n)
    n = n.to_f
    return "" if n <= 0.0
    sprintf("%2.f", n)
  end

end
