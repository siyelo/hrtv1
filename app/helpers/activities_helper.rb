module ActivitiesHelper
  def options_for_association_conditions(association)
    vals=[]
    if association.name == :provider
      unless @record.locations.empty?
        ["organization_id in (?)", 
          Organization.providers_for(@record.locations).collect {|o| o.id}]
      else
        super
      end
    else
      super
    end
  end
end
