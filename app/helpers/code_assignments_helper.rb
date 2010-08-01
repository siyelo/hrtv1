module CodeAssignmentsHelper
  # this is good because we can have pages w multiple codings
  # and it lets us go back and forth between them and the ui
  def activity_model_attribute_to_update coding_type
    if coding_type == :budget_codes
      'budget_codes_updates'
    elsif coding_type == :expenditure_codes
      'expenditure_codes_updates'
    elsif coding_type == :budget_cost_categories
      'budget_cost_categories_updates'
    elsif coding_type == :expenditure_cost_categories
      'expenditure_cost_categories_updates'
    end
  end
end
