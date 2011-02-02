module SortOrder
  def self.get_sort_order(sort)
    case sort
    when "spent_desc"
      "spent_sum_raw DESC, budget_sum_raw DESC"
    when "spent_asc"
      "spent_sum_raw ASC, budget_sum_raw ASC"
    when "budget_desc"
      "budget_sum_raw DESC, spent_sum_raw DESC"
    when "budget_asc"
      "budget_sum_raw ASC, spent_sum_raw ASC"
    else
      "spent_sum_raw DESC, budget_sum_raw DESC" # when sort.blank?
    end
  end
end
