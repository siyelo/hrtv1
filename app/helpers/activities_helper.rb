module ActivitiesHelper
  def options_for_association_conditions(association)
    if params[:controller] == "activities" #this might intro a bug
      #right now for some reason projects is trying to pick up the
      #options for the association for activities
      if association.name == :provider
          ids = Set.new
          Project.all.each do |p| #in future this should scope right with default
            ids.merge p.providers
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
            Project.all.each do |p| #in future this should scope right with default
              ids.merge p.location_ids
            end
            ["id in (?)", ids]
          end
      else
        super
      end
    end
  end
end
