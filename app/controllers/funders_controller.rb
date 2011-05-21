class FundersController < Reporter::BaseController
  before_filter :load_data_response
  before_filter :load_projects

  def edit
  end

  def update
    #Activity.bulk_update(@response, params[:activities])
    #flash[:notice] = 'Workplan was successfully saved'
    #redirect_to edit_response_workplan_url(@response, params[:id])
  end

  private
    def load_projects
      @projects = @response.projects.find(:all, :order => "id ASC")
    end
end
