module StaticPageHelper

  def display_warnings(warnings)
    if warnings.include?(:other_costs_missing)
      "We noticed you did not enter any #{link_to('other costs', other_costs_path)}. Have you entered all of your expenditure and budget information?"
    elsif warnings.include?(:activities_missing)
      "We noticed you did not enter any #{link_to('activities', activities_path)}. Have you entered all of your expenditure and budget information?"
    end
  end
end
