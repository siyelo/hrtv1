class Admin::DataResponsesController < ApplicationController
  before_filter :require_admin

  def index
    @submitted_data_responses = DataResponse.available_to(current_user).submitted.all
    @in_progress_data_responses = DataResponse.available_to(current_user).in_process
    @empty_data_responses = DataResponse.available_to(current_user).empty
  end

  def show
    @data_response = DataResponse.find(params[:id])
    @projects = @data_response.projects.find(:all, :order => "name ASC")
    @code_roots = Code.for_activities.roots
    @cost_cat_roots = CostCategory.roots
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
