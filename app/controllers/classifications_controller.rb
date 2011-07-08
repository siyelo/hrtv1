class ClassificationsController < Reporter::BaseController
  before_filter :load_data_response

  def edit
    @projects     = @response.projects.find(:all, :order => 'name ASC')
    @coding_tree  = CodingTree.new(Activity.new, params[:id].constantize)
    @codes        = @coding_tree.root_codes
  end

  def update
    CodeAssignment.mass_update_classifications(@response, params[:classifications], params[:id])
    flash[:notice] = 'Health Functions were successfully saved'
    redirect_to edit_response_classification_url(@response, params[:id])
  end
end
