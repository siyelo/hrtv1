module DataResponseHelper
  def display_warnings(warnings, data_response)
    if warnings.include?(:other_costs_missing)
      "We noticed you did not enter any #{link_to('other costs', response_other_costs_path(data_response))}. Have you entered all of your expenditure and budget information, including any financial information at the central level and administrative expenses?"
    elsif warnings.include?(:activities_missing)
      "We noticed you did not enter any #{link_to('activities', response_activities_path(data_response))}. Have you entered all of your expenditure and budget information?"
    end
  end
end
