class WorkplansController < Reporter::BaseController
  before_filter :load_data_response
  before_filter :load_projects
  before_filter :check_reporters_response

  def index
  end

  def update
    Activity.bulk_update(@response, params[:activities])
    flash[:notice] = 'Workplan was successfully saved'
    if params[:commit] == "Save"
      redirect_to response_workplans_url(@response)
    else
      redirect_to response_funders_path(@response)
    end
  end


  private
    def load_projects
      @projects = @response.projects.find(:all, :order => "id ASC")
    end
end
