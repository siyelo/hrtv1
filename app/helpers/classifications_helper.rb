module ClassificationsHelper
  def spend_coding_type
    if get_coding_type(params[:coding_type]) == :spend
      params[:coding_type]
    else
      Activity::CLASSIFICATION_MAPPINGS[params[:coding_type]]
    end
  end

  def budget_coding_type
    if get_coding_type(params[:coding_type]) == :budget
      params[:coding_type]
    else
      Activity::CLASSIFICATION_MAPPINGS.invert[params[:coding_type]]
    end
  end
end
