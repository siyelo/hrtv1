module CommoditiesHelper

  def commodities_options
    @cost_cats ||= CostCategory.roots.map(&:short_display)
  end
  
  def calculate_total(unit_cost, quantity)
    unit_cost * quantity
  end
end
