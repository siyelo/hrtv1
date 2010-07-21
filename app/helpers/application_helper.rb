# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Does not check that this is a valid class
  def controller_model_class
    c=controller_name.to_s.pluralize.singularize.camelize.constantize
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

  def unfulfill_responses 
    #<todo> need to add relate to users, currently,it goes through all responses
    DataResponse.unfulfilled
  end

end
