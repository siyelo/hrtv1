class ImplementersController < Reporter::BaseController
  before_filter :load_data_response
  before_filter :load_projects

  def edit
  end

  def update
    @activity = @response.activities.find(params[:activity_id])
    @activity.update_attributes(:sub_activities_attributes => params[:classifications])
    respond_to do |format|
      format.html do
        flash[:notice] = 'Implementers were successfully saved'
        redirect_to edit_response_workplan_url(@response, params[:id])
      end
      format.js do
        #TODO
        render :partial => 'implementer_row', :locals => {
          :project => @activity.project,
          :activity => @activity
        }
      end
    end
  end

  private

    def load_projects
      @projects = @response.projects.find(:all, :order => "id ASC")
    end
end
