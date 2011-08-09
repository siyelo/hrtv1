module Activity::Validations
  def has_budget_or_spend?
    spend.present? || budget.present?
  end
end
