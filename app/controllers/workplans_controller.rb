class WorkplansController < Reporter::BaseController
  before_filter :load_data_response

  def index
    @projects = @response.projects.all
  end

  def edit
    @projects = @response.projects.all
  end

  def update
    redirect_to edit_response_workplan_url(@response, params[:id])
  end
end
