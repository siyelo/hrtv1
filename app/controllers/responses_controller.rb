class ResponsesController < Reporter::BaseController
  layout 'reporter' #TODO: separate reporter/admin actions
  before_filter :require_user

  def new
    @response = DataResponse.new(:data_request_id => params[:data_request_id])
  end

  def review
    @response                     = find_response(params[:id])
    @projects                     = @response.projects.find(:all, :order => "name ASC")
    @activities_without_projects  = @response.activities.roots.without_a_project
    @other_costs_without_projects = @response.other_costs.without_a_project
    @code_roots                   = Code.purposes.roots
    @cost_cat_roots               = CostCategory.roots
    @other_cost_roots             = OtherCostCode.roots
    @policy_maker                 = true #view helper
  end

  # POST /data_responses
  def create
    @response  = DataResponse.new(params[:data_response])
    @response.organization = current_user.organization

    if @response.save
      current_user.current_response = @response
      current_user.save
      flash[:notice] = "Your response was successfully created. You can edit your preferences on the Settings tab."
      redirect_to response_projects_path(@response)
    else
      render :action => :new
    end
  end

  def submit
    @response = find_response(params[:id])
    @projects = @response.projects.find(:all, :include => :normal_activities)
  end

  def send_data_response
    @response = find_response(params[:id])
    @projects = @response.projects.find(:all, :include => :normal_activities)
    if @response.submit!
      flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      redirect_to review_response_url(@response)
    else
      render :submit
    end
  end
end
