class DataResponsesController < ApplicationController
  before_filter :load_help
  def start
    @data_response = DataResponse.available_to(current_user).find params[:id]
    current_user.current_data_response = @data_response
    current_user.save
  end

  def edit
    @data_response = DataResponse.available_to(current_user).find params[:id]
    @data_response.update_attributes params[:data_response]
    if @data_response.save
      flash[:notice] = "Successfully updated."
      redirect_to data_response_start_url(@data_response.id)
    else
      flash[:error] = "Something went wrong, if this happens repeatedly, contact an administrator."
      render :action => :start
    end

  end

  def submit
    @data_response = DataResponse.available_to(current_user).find params[:id]
    @data_response.submitted = true
    @data_response.save
  end

  protected

  def load_help
    @model_help = ModelHelp.find_by_model_name 'DataResponse'
  end
end
