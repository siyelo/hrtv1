module ClassificationsHelper
  def friendly_name_for_coding_copy(coding_type)
    case coding_type
    when 'CodingBudget', 'CodingSpend'
      'Purposes'
    when 'CodingBudgetDistrict', 'CodingSpendDistrict'
      'Locations'
    when 'CodingBudgetCostCategorization', 'CodingSpendCostCategorization'
      'Inputs'
    end
  end

  def spend_or_budget(coding_type)
    case coding_type
    when 'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization', 'HsspBudget'
      "current budget"
    when 'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization', 'HsspSpend'
      "expenditure"
    end
  end

  def tab_class(activity, current_coding_type, coding_type)
    classes = []
    classes << 'incomplete' unless activity.classified_by_type?(coding_type)
    classes << 'selected' if current_coding_type == coding_type
    classes.join(' ')
  end

  def get_coding_type(klass)
    case klass.to_s
    when 'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization'
      :budget
    when 'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization'
      :spend
    else
      raise "Invalid coding_klass #{klass.to_s}".to_yaml
    end
  end

  def node_error(code, assignment)
    "Amount of this node is not same as the sum of children amounts underneath (#{assignment.cached_amount} - #{assignment.sum_of_children} = #{assignment.cached_amount - assignment.sum_of_children})."
  end

  def all_view?
    params[:view] != 'my'
  end

  def code_classified?(budget_assignments, spend_assignments, code)
    budget_assignments.has_key?(code.id) || spend_assignments.has_key?(code.id)
  end

  def percentage_field_options(code, assignment, valid)
    valid ? {:title => node_error(code, assignment), :class => "tooltip invalid_node"} : {}
  end
end
