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
end
