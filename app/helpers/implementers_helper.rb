module ImplementersHelper

  def get_spend_value(implementer)
    if implementer.spend
      implementer.spend
    elsif implementer.spend_percentage
      "#{implementer.spend_percentage}%"
    else
      ""
    end
  end

  def get_budget_value(implementer)
    if implementer.budget
      implementer.budget
    elsif implementer.budget_percentage
      "#{implementer.budget_percentage}%"
    else
      ""
    end
  end
end
