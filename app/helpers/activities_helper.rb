module ActivitiesHelper
  def options_for_association_conditions(association)
    vals=[]
    if association.name == :provider
      super # make ["organization_id in (?)", @record.providers]
    else
      super
    end
  end
end
