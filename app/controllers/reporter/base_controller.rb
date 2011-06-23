class Reporter::BaseController < ApplicationController

  ### Layout
  layout 'reporter'

  ### Filters
  before_filter :require_user
  before_filter :warn_if_not_current_request

  protected

    def not_latest_request_message(request)
      "You are now viewing your data for the Request: \"<span class='bold'>#{request.name}</span>\".
       All changes made will be saved for this Request.
       Would you like to <a href='#{reporter_set_latest_response_path}'>resume editing the latest Request?</a>"
    end

  private

    def load_data_response
      if current_user.admin?
        # work-arround until all admin actions are moved to admin controllers
        @response = DataResponse.find(params[:response_id])
      else
        @response = current_user.data_responses.find(params[:response_id])
      end
    end

    def load_comment_resources(resource)
      @comment = Comment.new
      @comment.commentable = resource
      @comments = resource.comments.find(:all, :order => 'created_at DESC')
    end

    def warn_if_not_current_request
      unless current_user.current_response_is_latest?
        flash.now[:warning] = not_latest_request_message(current_user.current_response.request)
      end
    end

end
