class Reporter::BaseController < ApplicationController
  layout 'reporter'
  before_filter :require_user

  private

    def load_data_response
      @data_response = DataResponse.find(params[:response_id])
    end
end
