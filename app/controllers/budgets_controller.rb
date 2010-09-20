class BudgetsController < ClassificationsController

  @@shown_columns = [ :name, :budget_completed?, :budget_by_district_completed?, :budget_by_cost_category_completed? ]

  active_scaffold :activity do |config|
    config.label          = 'Activity Budget Classifications'
  end

  def popup_classification
    redirect_to budget_activity_coding_url(params[:id])
  end

end
