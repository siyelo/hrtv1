module ClassificationsHelper
  def spend_coding_type(type)
    if get_coding_type(type) == :spend
      type
    else
      Activity::CLASSIFICATION_MAPPINGS[type]
    end
  end

  def budget_coding_type(type)
    if get_coding_type(type) == :budget
      type
    else
      Activity::CLASSIFICATION_MAPPINGS.invert[type]
    end
  end

  def find_existing_assignments(activity)
    activity.code_assignments.with_type(params[:id]).find(:all,
    :order => 'codes.short_display',
    :joins => :code,
    :conditions => 'amount IS NOT NULL OR percentage IS NOT NULL')
  end

  def cached_amount_total(code_assignments)
    # !!! CAUTION: this is disabled because
    # classified amount caches are disabled
    #
    # code_assignments.map{|ca| ca.cached_amount}.sum

    code_assignments.map{|ca| ca.amount}.sum
  end

  def getting_started_partial(coding_type)
    case coding_type
    when 'CodingBudget', 'CodingSpend'
      'purposes'
    when 'CodingBudgetDistrict', 'CodingSpendDistrict'
      'locations'
    when 'CodingBudgetCostCategorization', 'CodingSpendCostCategorization'
      'inputs'
    when 'ServiceLevelBudget', 'ServiceLevelSpend'
      'service_levels'
    end
  end
end

