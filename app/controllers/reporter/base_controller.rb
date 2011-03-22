class Reporter::BaseController < ApplicationController

  ### Layout
  layout 'reporter'

  ### Filters
  before_filter :require_user

  private

    def load_data_response
      @data_response = DataResponse.find(params[:response_id])
    end
end
