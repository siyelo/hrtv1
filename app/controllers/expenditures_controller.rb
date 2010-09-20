class ExpendituresController < ClassificationsController

  @@shown_columns = [ :name, :expenditure_completed?, :expenditure_by_district_completed?, :expenditure_by_cost_category_completed? ]

  active_scaffold :activity do |config|
    config.label          = 'Activity Expenditure Classifications'
  end

  def popup_coding
    redirect_to expenditure_activity_coding_url(params[:id])
  end

end
