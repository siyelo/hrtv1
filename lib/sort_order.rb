module SortOrder
  def self.get_sort_order(sort)
    case sort
    when "spent_desc"
      "spent_sum DESC, budget_sum DESC"
    when "spent_asc"
      "spent_sum ASC, budget_sum ASC"
    when "budget_desc"
      "budget_sum DESC, spent_sum DESC"
    when "budget_asc"
      "budget_sum ASC, spent_sum ASC"
    else
      "spent_sum DESC, budget_sum DESC" # when sort.blank?
    end
  end
end
