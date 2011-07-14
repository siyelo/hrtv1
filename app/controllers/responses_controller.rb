class ResponsesController < Reporter::BaseController
  before_filter :require_user
  before_filter :load_response_from_id, :except => :new

  def review
    @projects                     = @response.projects.find(:all, :order => "name ASC", :select => 'projects.name, projects.description')
    @activities_without_projects  = @response.activities.roots.without_a_project
    @other_costs_without_projects = @response.other_costs.without_a_project
    @code_roots                   = Code.purposes.roots
    @cost_cat_roots               = CostCategory.roots
    @other_cost_roots             = OtherCostCode.roots
    @policy_maker                 = true #view helper
  end

  def submit
    # NOTE: old code
    #@projects = @response.projects.find(:all, :include => :normal_activities)

    # NOTE: optimization
    DataResponse.send(:preload_associations, @response,
                  [{:projects => :normal_activities}])
    @projects = @response.projects
  end

  def send_data_response
    @projects = @response.projects.find(:all, :include => :normal_activities)
    if @response.submit!
      flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      redirect_to review_response_url(@response)
    else
      render :submit
    end
  end
end
