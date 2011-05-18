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
    code_assignments.map{|ca| ca.cached_amount}.sum
  end

end

