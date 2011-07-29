class ClassificationsController < Reporter::BaseController
  before_filter :load_data_response

  def edit
    @projects     = @response.projects.find(:all, :order => 'name ASC')
    @purpose_row  = render_to_string(:partial => 'purpose_row.html.haml',
                       :locals => {:ca => nil, :activity => nil})
  end

  def update
    CodeAssignment.mass_update_classifications(@response, params[:classifications], params[:id])
    flash[:notice] = 'Health Functions were successfully saved'
    if params[:commit] == 'Save'
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
