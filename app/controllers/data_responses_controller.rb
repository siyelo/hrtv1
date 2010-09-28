class DataResponsesController < ApplicationController
  before_filter :load_help
  before_filter :require_user
  before_filter :require_admin, :only => [:index]

  def index
    @data_responses = DataResponse.submitted.all
  end

  def show
    @data_response = DataResponse.available_to(current_user).find params[:id]
  end

  def start
    @data_response = DataResponse.available_to(current_user).find params[:id]
    current_user.current_data_response = @data_response
    current_user.save
    render :action => 'show'
  end

  def update
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
    @data_response = DataResponse.available_to(current_user).find params[:id]
    root_activities         = @data_response.activities.roots
    other_cost_activities   = @data_response.activities.with_type("OtherCost")
    @uncoded_activities     = root_activities.reject{ |a| a.classified }
    @uncoded_other_costs    = other_cost_activities.reject{ |a| a.classified }
    @warnings               = []
    @warnings               << :other_costs_missing if other_cost_activities.empty?
    @warnings               << :activities_missing  if root_activities.empty?
  end

  def submit
    @data_response = DataResponse.available_to(current_user).find params[:id]
    @data_response.submitted = true
    @data_response.submitted_at = Time.now
    @data_response.save
    flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
    redirect_to data_response_url(@data_response)
  end

  protected

  def load_help
    @model_help = ModelHelp.find_by_model_name 'DataResponse'
  end
end
