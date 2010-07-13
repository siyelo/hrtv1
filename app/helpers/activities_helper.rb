module ActivitiesHelper
  def options_for_association_conditions(association)
    if association.name == :provider
        ids=Set.new
        Project.all.each do |p| #in future this should scope right with default
          ids.merge p.valid_providers
        end
        ["id in (?)", 
          ids]
    else
      super
    end
  end
end
