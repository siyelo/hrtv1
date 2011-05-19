class ClassificationsController < Reporter::BaseController
  before_filter :load_data_response

  def edit
    @projects = @response.projects.all
    @coding_type = params[:coding_type] || 'CodingBudget'
    # We just want the root codes for an Activity Type for now
    @coding_tree         = CodingTree.new(Activity.new, @coding_type.constantize)
    @codes               = @coding_tree.root_codes
  end

  def update
    @activity = @response.activities.find(params[:activity_id])
    CodeAssignment.update_classifications(@activity, params[:classifications], params[:id])
    flash[:notice] = 'Purposes classifications for Spent were successfully saved'
    redirect_to edit_response_classification_url(@response, params[:id])
  end

  def destroy
    ca = @response.code_assignments.find(params[:id])
    activity = ca.activity
    klass = ca.class
    ca.destroy
    activity.update_classified_amount_cache(klass)

    render :json => {:status => true}
  end
end
