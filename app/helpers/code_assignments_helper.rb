module CodeAssignmentsHelper
  # TODO refactor this and remove entirely
  def activity_model_attribute_to_update coding_type
    if coding_type == :budget
      'budget_amounts'
    elsif coding_type == :expenditure
      'expenditure_amounts'
    elsif coding_type == :budget_cost_categories
      'budget_cost_categories'
    elsif coding_type == :expenditure_cost_categories
      'expenditure_cost_categories'
    end
  end
end
