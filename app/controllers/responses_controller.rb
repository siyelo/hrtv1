class ResponsesController < ApplicationController
  layout 'reporter' #TODO: separate reporter/admin actions
  before_filter :require_user

  def new
    @data_response = DataResponse.new
  end

  def show
    @response = @data_response    = find_response(params[:id])
    @projects                     = @data_response.projects.find(:all, :order => "name ASC")
    @activities_without_projects  = @data_response.activities.roots.without_a_project
    @other_costs_without_projects = @data_response.other_costs.without_a_project
    @code_roots                   = Code.purposes.roots
    @cost_cat_roots               = CostCategory.roots
    @other_cost_roots             = OtherCostCode.roots
    @policy_maker                 = true #view helper
  end

  # POST /data_responses
  def create
    @data_response  = DataResponse.new(params[:data_response])
    @data_response.organization = current_user.organization

    if @data_response.save
      current_user.current_data_response = @data_response
      current_user.save
      flash[:notice] = "Your response was successfully created. You can edit your preferences on the Settings tab."
      redirect_to response_projects_path(@data_response)
    else
      render :action => :new
    end
  end

  def edit
    @data_response = find_response(params[:id])
    current_user.current_data_response = @data_response
    current_user.save
  end

  def update
    @data_response = find_response(params[:id])
    @data_response.update_attributes(params[:data_response])
    if @data_response.save
      flash[:notice] = "Successfully updated."
      redirect_to edit_response_url(@data_response)
    else
      render :action => :edit
    end
  end

  def review
  end

  def submit
    if @data_response.submit!
      flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      redirect_to review_response_url(@data_response)
    else
      render :review
    end
  end
end
