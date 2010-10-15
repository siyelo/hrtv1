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
  end

  def destroy
    respond_to do |format|
      @data_response = DataResponse.find(params[:id])
      if @data_response.empty? #TODO move into model
        if @data_response.destroy
          flash[:notice] = "Successfully deleted data response for #{@data_response.responding_organization}."
        else
          flash[:error] = "Error deleting data response"
        end
      else
        flash[:error] = "Can't delete a data response that contains data"
      end
      format.html { redirect_to data_responses_url }
    end
  end
end
