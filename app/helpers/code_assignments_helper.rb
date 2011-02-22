module CodeAssignmentsHelper
  def friendly_name_for_coding_copy(coding_type)
    case coding_type
    when 'CodingBudget'
      "Coding"
    when 'CodingBudgetDistrict', 'CodingSpendDistrict'
      "District"
    when 'CodingBudgetCostCategorization'
      "Cost Category"
    end
  end

  def spend_or_budget(coding_type)
    case coding_type
    when 'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization'
      "budget"
    when 'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization'
      "expenditure"
    end
  end
end
