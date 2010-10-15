class Admin::DataResponsesController < ApplicationController
  before_filter :require_admin

  def index
    # TODO add exempted category, link to exempt next to each empty response
    @model_help = ModelHelp.find_by_model_name 'DataResponseIndex'
    @submitted_data_responses = DataResponse.available_to(current_user).submitted.all
    @in_progress_data_responses = DataResponse.available_to(current_user).in_process
    @empty_data_responses = DataResponse.available_to(current_user).empty
  end

  def destroy
    respond_to do |format|
      @data_response = DataResponse.available_to(current_user).find params[:id]
      if @data_response.empty? #TODO move into model
        if @data_response.destroy
          flash[:notice] = "Successfully deleted data response for #{@data_response.responding_organization}."
        else
          flash[:error] = "Error deleting data response"
        end
      else
          flash[:error] = "Can't delete a data response that contains data"
      end
      format.html { redirect_to data_responses_url() }
    end
  end
end
