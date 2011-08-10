module Activity::Validations

  def has_budget_or_spend?
    spend.present? || budget.present?
  end

  # TODO: spec
  def classification_errors_by_type(type)
    errors = []

    case type
    when 'purposes'
      errors << 'Purposes by Current Budget are not classified' unless coding_budget_classified?
      errors << 'Purpsoes by Past Expenditure are not classified' unless coding_spend_classified?
    when 'inputs'
      errors << 'Inputs by Current Budget are not classified' unless coding_budget_cc_classified?
      errors << 'Inputs by Past Expenditure are not classified' unless coding_spend_cc_classified?
    when 'locations'
      errors << 'Inputs by Current Budget are not classified' unless coding_budget_district_classified?
      errors << 'Inputs by Past Expenditure are not classified' unless coding_spend_district_classified?
    else
      raise "Invalid type #{type}".to_yaml
    end

    errors
  end
end
