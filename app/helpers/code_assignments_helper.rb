module CodeAssignmentsHelper
  def friendly_name_for_coding_copy(coding_type)
      case coding_type
      when 'CodingBudget'
        "Coding"
      when 'CodingBudgetDistrict'
        "District"
      when 'CodingBudgetCostCategorization'
        "Cost Category"
      end
  end
end
