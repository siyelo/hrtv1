class ResponsesController < ApplicationController
  layout 'reporter' #TODO: separate reporter/admin actions
  before_filter :require_user

  def new
    @response = DataResponse.new
  end

  def show
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
      current_user.current_data_response = @response
      current_user.save
      flash[:notice] = "Your response was successfully created. You can edit your preferences on the Settings tab."
      redirect_to edit_response_workplan_path(@response, :spend)
    else
      render :action => :new
    end
  end

  def edit
    @response = find_response(params[:id])
    current_user.current_data_response = @response
    current_user.save
  end

  def update
    @response = find_response(params[:id])
    @response.update_attributes(params[:data_response])
    if @response.save
      flash[:notice] = "Successfully updated settings."
      redirect_to edit_response_url(@response)
    else
      render :action => :edit
    end
  end

  def review
    @response = find_response(params[:id])
  end

  def submit
    @response = find_response(params[:id])
    if @response.submit!
      flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      redirect_to review_response_url(@response)
    else
      render :review
    end
  end
end
