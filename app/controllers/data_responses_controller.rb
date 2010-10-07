class DataResponsesController < ApplicationController

  before_filter :require_user
  before_filter :require_admin, :only => [:index]

  def index
    @model_help = ModelHelp.find_by_model_name 'DataResponseIndex'
    @data_responses = DataResponse.available_to(current_user).submitted.all
  end

  def show
    @model_help = ModelHelp.find_by_model_name 'DataResponse'
    @data_response = DataResponse.available_to(current_user).find params[:id]
  end

  # POST /data_responses
  def create
    respond_to do |format|
      @data_response = DataResponse.new(params[:data_response])
      if @data_response.save
        format.html { redirect_to( :action => 'start', :id => @data_response.id ) }
      else
        flash[:error] = "Couldn't create your response"
        format.html { redirect_to reporter_dashboard_url() }
      end
    end
  end

  def start
    @model_help = ModelHelp.find_by_model_name 'DataResponse'
    @data_response = DataResponse.available_to(current_user).find params[:id]

    current_user.current_data_response = @data_response
    current_user.save
    render :action => 'show'
  end

  def update
    @model_help = ModelHelp.find_by_model_name 'DataResponse'
    @data_response = DataResponse.available_to(current_user).find params[:id]
    @data_response.update_attributes params[:data_response]
    if @data_response.save
      flash[:notice] = "Successfully updated."
      redirect_to data_response_url(@data_response)
    else
      render :action => :show
    end
  end

  def review
    @model_help = ModelHelp.find_by_model_name 'DataResponseReview'
    @data_response = DataResponse.available_to(current_user).find params[:id]
    root_activities         = @data_response.activities.roots
    other_cost_activities   = @data_response.activities.with_type("OtherCost")
    @uncoded_activities     = root_activities.reject{ |a| a.classified || (a.budget_classified? && !a.spend_classified?)  }
    @uncoded_other_costs    = other_cost_activities.reject{ |a| a.classified || (a.budget_classified? && !a.spend_classified?)}
    @budget_activities      = root_activities.select{ |a| a.budget_classified? && !a.spend_classified? }
    @budget_other_costs     = other_cost_activities.select{ |a| a.budget_classified? && !a.spend_classified? }
    @warnings               = []
    @warnings               << :other_costs_missing if other_cost_activities.empty?
    @warnings               << :activities_missing  if root_activities.empty?
  end

  def submit
    @model_help = ModelHelp.find_by_model_name 'DataResponse'
    @data_response = DataResponse.available_to(current_user).find params[:id]
    @data_response.submitted = true
    @data_response.submitted_at = Time.now
    @data_response.save
    flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
    redirect_to data_response_url(@data_response)
  end
end
