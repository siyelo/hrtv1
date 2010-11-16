class Admin::DataResponsesController < ApplicationController
  before_filter :require_admin
  skip_before_filter :load_help

  def index
    @empty_data_responses       = DataResponse.available_to(current_user).empty
    @in_progress_data_responses = DataResponse.available_to(current_user).in_process
    @submitted_data_responses   = DataResponse.available_to(current_user).submitted.find(:all, :include => :responding_organization)
  end

  def show
    @data_response               = DataResponse.find(params[:id])
    @projects                    = @data_response.projects.find(:all, :order => "name ASC")
    @activities_without_projects = @data_response.activities.roots.without_a_project
    @code_roots                  = Code.for_activities.roots
    @cost_cat_roots              = CostCategory.roots
    @other_cost_roots            = OtherCostCode.roots
  end

  def destroy
    @data_response = DataResponse.find(params[:id])
    @data_response.destroy if @data_response.empty?

    respond_to do |format|
      format.html do
        flash[:notice] = "Data response was successfully deleted."
        redirect_to admin_data_responses_url
      end
      format.js   { render :nothing => true }
    end
  end

  def delete
    @data_response = DataResponse.find(params[:id])
  end
end
