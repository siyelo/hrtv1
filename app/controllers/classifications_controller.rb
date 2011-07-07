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
    debugger
    if params[:commit] == 'save'  
      redirect_to edit_response_classification_url(@response, params[:id])
    else
      if params[:id].match('Budget') 
        redirect_to response_long_term_budgets_path 
      else 
        redirect_to edit_response_classification_path(@response, @template.budget_coding_type(params[:id]))
      end
    end
  end
end
