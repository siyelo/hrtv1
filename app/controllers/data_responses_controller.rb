class DataResponsesController < ApplicationController
  def start
    @data_response = DataResponse.find params[:id]
    current_user.current_data_response = @data_response
  end
end
