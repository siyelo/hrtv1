class Reporter::BaseController < ApplicationController

  ### Layout
  layout 'reporter'

  ### Filters
  before_filter :require_user

  private

    def load_data_response
      if current_user.admin?
        # work-arround until all admin actions are moved to admin controllers
        @data_response = DataResponse.find(params[:response_id])
      else
        @data_response = current_user.organization.data_responses.find(params[:response_id])
      end
    end

    def load_comment_resources(resource)
      @comment = Comment.new
      @comment.commentable = resource
      @comments = resource.comments.find(:all, :order => 'created_at DESC')
    end
end
