module OtherCostsHelper
  def options_for_association_conditions(association)
    if params[:controller] == "other_costs" #this might intro a bug
      if association.name == :projects
          ids = Set.new
          Project.available_to(current_user).all.each do |p|
            ids.merge [p.id]
          end
          ["id in (?)", ids]
      else
        super
      end
    end
  end
end
