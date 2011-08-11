module Activity::Validations

  class InvalidClassificationType < StandardError; end

  def has_budget_or_spend?
    spend.present? || budget.present?
  end

  def classification_errors_by_type(type)
    errors = []

    case type
    when 'purposes'
      errors << 'Purposes by Current Budget are not classified' unless coding_budget_classified?
      errors << 'Purposes by Past Expenditure are not classified' unless coding_spend_classified?
    when 'inputs'
      errors << 'Inputs by Current Budget are not classified' unless coding_budget_cc_classified?
      errors << 'Inputs by Past Expenditure are not classified' unless coding_spend_cc_classified?
    when 'locations'
      errors << 'Locations by Current Budget are not classified' unless coding_budget_district_classified?
      errors << 'Locations by Past Expenditure are not classified' unless coding_spend_district_classified?
    else
      raise InvalidClassificationType
    end

    errors
  end
end
