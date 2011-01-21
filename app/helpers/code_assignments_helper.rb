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

  def coding_progress(activity)
    coded = 0
    coded +=1 if activity.budget?
    coded +=1 if activity.budget_by_district?
    coded +=1 if activity.budget_by_cost_category?
    coded +=1 if activity.spend?
    coded +=1 if activity.spend_by_district?
    coded +=1 if activity.spend_by_cost_category?
    progress = (coded.to_f / 6) * 100
  end
end
