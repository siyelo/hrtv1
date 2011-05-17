class ClassificationsController < Reporter::BaseController
  before_filter :load_data_response

  def edit
    @projects = @response.projects.all
  end

  def update
    @activity = @response.activities.find(params[:activity_id])
    CodeAssignment.update_classifications(@activity, params[:classifications], params[:coding_type])
    flash[:notice] = 'Purposes classifications for Spent were successfully saved'
    redirect_to edit_response_classifications_url(@response, 
                                                  :coding_type => params[:coding_type])
  end
end
