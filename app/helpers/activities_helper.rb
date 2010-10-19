module ActivitiesHelper
  def label_string model_class, column
    if model_class == Activity
      ActivitiesController.label_for column
    elsif model_class == OtherCost
      OtherCostsController.label_for column
    end
  end
  def options_for_association_conditions(association)
    if params[:controller] == "other_costs"
      if association.name == :projects
          ids = Set.new
          Project.available_to(current_user).all.each do |p|
            ids.merge [p.id]
          end
          ["id in (?)", ids]
      else
        super
      end
    elsif params[:controller] == "activities" #this might intro a bug
      #right now for some reason projects is trying to pick up the
      #options for the association for activities
      logger.debug("in 2")
      if association.name == :provider
          ids = Set.new
          Project.available_to(current_user).all.each do |p|
            ids.merge p.providers
          end
          ["id in (?)", ids]
      elsif association.name == :projects
          ids = Set.new
          Project.available_to(current_user).all.each do |p|
            ids.merge [p.id]
          end
          ["id in (?)", ids]
      elsif association.name == :locations
          unless @record.projects.empty?
            ids=Set.new
            @record.projects.each do |p| #in future this should scope right with default
              ids.merge p.location_ids
            end
            ["id in (?)", ids]
          else
            ids=Set.new
            Project.available_to(current_user).all.each do |p| #in future this should scope right with default
              ids.merge p.location_ids
            end
            ["id in (?)", ids]
          end
      else
        super
      end
    end
  end

  # Active Scaffold fields override
  def start_form_column(column, options)
    text_field :record, :start, options.merge({:class => "date_picker"})
  end

  def end_form_column(column, options)
    text_field :record, :end, options.merge({:class => "date_picker"})
  end

  def popup_classify_link_for activity
    link_to("Classify", popup_classification_classification_url(activity.id))
  end
end
